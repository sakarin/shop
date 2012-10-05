Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :locations
  end
end