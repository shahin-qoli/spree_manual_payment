module SpreeBrxManualPayment::Storefront::CheckoutControllerDecorator
	def serialize_payment_methods(payment_methods)
		params = serializer_params
		params[:available_user_store_credit] = spree_current_order.user.total_available_store_credit

		payment_methods_serializer.new(payment_methods, params: params).serializable_hash
	end

	def settle_payments
		result = brx_payment_settlement_service.new(order:spree_current_order,
			params: permitted_settle_payments).call
		render json: {next_link: result}
	rescue StandardError => e
		render json: {error: e.message}, status: 400
	end

	def permitted_settle_payments
params.permit(:success_url,:failure_url,:error_url,payments: [:payment_method_id, :amount])
	end

	def brx_payment_settlement_service
		::Spree::PaymentSettlement::HandlePayments
	end
end

Spree::Api::V2::Storefront::CheckoutController.prepend(
SpreeBrxManualPayment::Storefront::CheckoutControllerDecorator
	)