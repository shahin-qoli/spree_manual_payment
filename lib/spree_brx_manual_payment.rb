require 'spree_core'
require 'spree_extension'
require 'spree_brx_manual_payment/engine'
require 'spree_brx_manual_payment/version'

module SpreeBrxManualPayment
    class Application < Rails::Application
      config.autoload_paths << Rails.root.join('lib')
      config.paths.add Rails.root.join('lib').to_s, eager_load: true
    end
end