module Spree
  class BrxController < ApplicationController
    def completion_route_brx(success_url, order_number)
      success_url+order_number
    end

    def error_route_brx(error_url, order_number)
      error_url+order_number
    end

    def failure_route_brx(failure_url, order_number)
      failure_url+order_number
    end
    def completion_route(order, custom_params = {})
      spree.order_path(order, custom_params.merge(locale: locale_param))
    end

    def payment_method
      Spree::PaymentMethod.where(type: 'Spree::Gateway::BrxGateway').first
    end 


    def verify_payment
      request_url  = 'https://shop.burux.com/api/PaymentService/Verify'
      options = {
      headers: {
        "Content-Type": "application/json",
      },

      body: [{ "RequestID": @request_id_brx, "Price": @amount_brx }].to_json
      }     
      begin
        response = HTTParty.post(request_url, options)
      rescue SocketError => e
         return {"result" => false, "error" => e}
      end

      if response.empty?
        return {"result" => false}
      end
          
      response_object = JSON.parse(response.body.tr('[]',''))
      if response_object['IsSuccess'] == true
        return {"result" => true}
      end
      {"result" => false}

    end
    def retry_verify
        @order_brx_number = params['order_number']
        @order_brx = Spree::Order.find_by_number(@order_brx_number)
        @order_id_brx = @order_brx.id
        @checkout_brx = Spree::BrxExpressCheckout.where(order_id: @order_id_brx).last
        if @checkout_brx.nil?
          render json: {"result" => false, "error" => "This user doesn't have any payment"} && return
        end
        @amount_brx = @checkout_brx['amount']
        @request_id_brx = @checkout_brx['request_id_brx']
        if @checkout_brx.is_used || @order_brx.complete || @order_brx.paid?
          render json: {"result" => true} && return
        end
        if verify_payment["result"] == true  
           @order_brx.payments.create!({
            source: Spree::BrxExpressCheckout.find_by(request_id: @request_id_brx),
            amount: @amount_brx, payment_method: payment_method
            })      

           unless @order_brx.complete?
              @order_brx.next    
           end

            payment = @order_brx.payments.last
            payment.complete! 
            @checkout_brx.is_used = true
            @checkout_brx.save!        
            session[:order_id] = nil
            render json: {"result" => true} && return
        end
        if verify_payment["result"] == false && verify_payment.key?("error")
            render json: {"result" => false, "error" => verify_payment['error']} && return
        else
            render json: {"result" => false} && return
        end
    end



    def getandverify
      @request_id_brx = params['reqid']
      @checkout_brx = Spree::BrxExpressCheckout.find_by request_id: @request_id_brx 
      if @checkout_brx.nil? 
          redirect_to spree_path && return
      end

      @success_url = @checkout_brx['success_url']
      @failure_url = @checkout_brx['failure_url']
      @error_url = @checkout_brx['error_url']
      @amount_brx = @checkout_brx['amount']
      @order_id_brx = @checkout_brx['order_id']
      @order_brx = Spree::Order.find(@order_id_brx)          
      @order_brx_number = @order_brx.number          
      if @checkout_brx.is_used && @checkout_brx.is_paied && order_brx.complete?
        redirect_to(completion_route_brx(@success_url,@order_brx_number))       
      elsif verify_payment["result"] == true  
        order_payment = @order_brx.payments.find_or_create_by!({
          source: Spree::BrxExpressCheckout.find_by(request_id: @request_id_brx),
          amount: @amount_brx, payment_method: payment_method
          }).complete!
        @order_brx.payments.select{|item| (item.state == "checkout" && item.payment_method.is_a?(Spree::PaymentMethod::StoreCredit)) }.last&.complete!
        @order_brx.finalize!
        @checkout_brx.is_paied = true
        @checkout_brx.save!        
        session[:order_id] = nil
        redirect_to(completion_route_brx(@success_url,@order_brx_number))
      elsif verify_payment["result"] == false && verify_payment.key?("error")
        Spree::Checkout::RemoveStoreCredit.new.call(order: @order_brx)
        redirect_to(error_route_brx(@error_url,@order_brx_number)) 
      else
        Spree::Checkout::RemoveStoreCredit.new.call(order: @order_brx)
        redirect_to(failure_route_brx(@failure_url,@order_brx_number))
      end
    end   
  end
end    
