Spree::Core::Engine.routes.draw do


  # Add your extension routes here

  Spree::Core::Engine.routes.prepend do

    match '/admin', :to => 'admin/orders#index', :as => :admin

    match 'admin/purchase_orders/download', :to => "admin/purchase_orders#download"

    # modify checkout process
    match '/checkout', :to => 'checkout#edit', :state => 'delivery', :as => :checkout

    namespace :admin do

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

    end

  end
end
