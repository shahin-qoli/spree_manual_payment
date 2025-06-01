module Spree
class PaymentMethod::ManualPayment < ::Spree::PaymentMethod
    def actions
      %w{capture void}
    end
    def authorize(_money, credit_card, _options = {})
      ActiveMerchant::Billing::Response.new(true, 'ManualPayment: Forced success', {}, test: true, authorization: '12345', avs_result: { code: 'D' })
    end
    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(*)
      simulated_successful_billing_response
    end
    def purchase(*)
      simulated_successful_billing_response
    end
    def cancel(*)
      simulated_successful_billing_response
    end

    def void(*)
      simulated_successful_billing_response
    end

    def source_required?
      true
    end

    def credit(*)
      simulated_successful_billing_response
    end

    def payment_source_class
      Spree::ManualPaymentSource
    end

    private

    def simulated_successful_billing_response
      ActiveMerchant::Billing::Response.new(true, '', {}, {})
    end
  end
end