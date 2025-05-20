
Rails.application.routes.draw do
  get "admin/home"
  devise_for :users, controllers: { registrations: "users/registrations" }
  get "page/index"
  root "page#index"
  post "create_playlist", to: "playlist#create", as: :create_playlist
  get "search", to: "page#search", as: :search
  get "list/:id", to: "page#list", as: :list
  get "album/:id", to: "page#album_details", as: :album_details
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
