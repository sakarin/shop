Shop::Application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'

  Spree::Core::Engine.routes.prepend do

    match '/admin', :to => 'admin/orders#index', :as => :admin

    match 'admin/purchase_orders/download', :to => "admin/purchase_orders#download"
    match 'admin/orders/:order_id/purchase_orders', :to => "admin/purchase_orders#purchase_by_order"
    match 'admin/orders/:order_id/receive_orders', :to => "admin/receive_products#receive_orders"

    match 'admin/shipments/print', :to => "admin/shipments#print"
    match 'admin/shipments/preview', :to => "admin/shipments#preview"

    # modify checkout process
    match '/checkout', :to => 'checkout#edit', :state => 'delivery', :as => :checkout

    match '/admin/shipments', :to => "admin/shipments#home"
    match 'admin/shipments/download', :to => "admin/shipments#download"

    match '/confirm/orders/:order_id/checkout/paypal_confirm(.:format)' => 'paypal_confirm#paypal', :via => [:get, :post]

    namespace :admin do
      resources :excels
      resources :suppliers
      resources :purchase_orders do
        resources :receive_products
        resources :refunds do
          member do
            put :fire
          end
        end
      end

      resources :refund_products do
        member do
          put :fire
        end
      end

      resources :shipments do
        member do
          put :fire
          get :home
        end
      end

    end

  end
    
end
