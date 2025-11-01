Spree::Core::Engine.add_routes do
  get "/Payment/Go/:reqid/:price/:type/:payid/:bankres", :to => "brx#getandverify", :as => :get_verify

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resource :checkout, controller: :checkout, only: %i[update] do
          post :settle_payments
        end        
      end
    end
  end
end