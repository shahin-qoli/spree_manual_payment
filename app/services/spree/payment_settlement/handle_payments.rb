module Spree::PaymentSettlement
	class HandlePayments
		def initialize(order:,params:)
			puts payments
			@params = params
			@order = order
			@payments= params["payments"]
			@outstanding_balance = order.outstanding_balance
			@available_store_credit = order.user.total_available_store_credit
		end
		attr_accessor :order,:payments,:outstanding_balance, :available_store_credit,:params
		def call
			ids = payments.map{|item| item["payment_method_id"]}
			pms = Spree::PaymentMethod.where(id: ids)
			if pms.size == 1
				payment_method = pms.last

				if payment_method.type.eql? store_credit_class
					if outstanding_balance <= available_store_credit
						hanlde_user_store_credit(outstanding_balance)
						order.reload.payments.select{|item| (item.state == "checkout" && item.payment_method.is_a?(Spree::PaymentMethod::StoreCredit)) }.last&.complete!
						if @order_brx.reload.paid? 
		          while !@order_brx.complete?
		            if !@order_brx.next
		              break
		            end
		          end
		        else
		        	return failure_route_brx(params['success_url'],order.number)
		        end
						return completion_route_brx(params['success_url'],order.number)
					else
						raise "مبلغ کیف پول کمتر از مبلغ سفارش است"
					end
				else
					return handle_generate_link(amount: outstanding_balance)
				end
			else
				if pms.any?{|item| item.type.eql? store_credit_class}
					if  available_store_credit > 0
						hanlde_user_store_credit(available_store_credit)
						return handle_generate_link(amount: order.order_total_after_store_credit)
					else
						return handle_generate_link(amount: outstanding_balance)
					end 
				else
					return handle_generate_link(amount: outstanding_balance)
				end
			end
		end
		def hanlde_user_store_credit(amount)
			add_store_credit_service.new.call(order: order, amount: amount)
		end
		def store_credit_class
			"Spree::PaymentMethod::StoreCredit"
		end
		def handle_generate_link(amount:)
			order_id = order.id
			amount = amount
			success_url = params['success_url']
			failure_url = params['failure_url']
			error_url = params['error_url']
			request_url  = 'https://shop.burux.com/api/PaymentService/Request'
			response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
			       :Type => 'Inv', 
			       :Price => amount, 
			       :Model => "{orderID: #{order_id}}", 
			       :CallbackAction => '5',
			       :ForceRedirectBank => 'true',
			       :CallbackUrl => 'http://shopback.miarze.com/Payment/Go/{reqid}/{price}/{type}/{payid}/{bankres}', 
			     }.to_json,
			:headers => { 'Content-Type' => 'application/json' }})
			response_object = JSON.parse(response.body)
			payment_url = response_object['InvoiceUrl']
			request_id = response_object['RequestID']
			Spree::BrxExpressCheckout.create({
			  request_id: request_id,  #53593b29-81c2-4f4b-afa3-a2d96a32c92c
			  amount: amount, 
			  order_id: order_id,
			  success_url: success_url,
			  failure_url: failure_url,
			  error_url: error_url
			})
			payment_url
		end		
		def add_store_credit_service
			::Spree::Checkout::AddStoreCredit
		end
    def completion_route_brx(success_url, order_number)
      success_url+order_number
    end		
    def error_route_brx(error_url, order_number)
      error_url+order_number
    end

    def failure_route_brx(failure_url, order_number)
      failure_url+order_number
    end    
	end
end