Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :stores
  end

  namespace :api do
    scope :module => :v1 do
      resources :stores do
      	collection do
      		get :search
        end
  	  end
    end
  end
  
  
end


