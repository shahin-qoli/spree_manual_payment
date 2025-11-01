module SpreeBrxManualPayment::PaymentMethodSerializerDecorator
	def self.prepended(base)
		base.attribute :available_user_store_credit do |pm, params|

			if pm.type.eql? "Spree::PaymentMethod::StoreCredit"
				params[:available_user_store_credit]
			else
				"Not Available"
			end
		end
	end
end

Spree::V2::Storefront::PaymentMethodSerializer.prepend(SpreeBrxManualPayment::PaymentMethodSerializerDecorator)
