Spree::Core::Engine.routes.draw do


  # Add your extension routes here

  Spree::Core::Engine.routes.prepend do

    match '/admin', :to => 'admin/orders#index', :as => :admin

    namespace :admin do
      resources :suppliers
    end

  end
end
