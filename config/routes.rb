Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  
  get "home", to: "home#user_home"

  namespace :api do
    namespace :v1 do
      defaults format: :json do
        
        post "blobs", to: "blobs#store"

        get "blobs/:id", to: "blobs#retrieve"
      end
    end
  end
end