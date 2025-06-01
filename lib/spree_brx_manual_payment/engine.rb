module SpreeBrxManualPayment
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_brx_manual_payment'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_brx_manual_payment.environment', before: :load_config_initializers do |_app|
      SpreeBrxManualPayment::Config = SpreeBrxManualPayment::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    config.after_initialize do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::ManualPayment
    end
  end
end
