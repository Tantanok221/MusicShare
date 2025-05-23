Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  get "page/index"
  root "page#index"
  get "album", to: "page#search", as: :search
  get "playlist/:id", to: "page#playlist_details", as: :playlist_details
  get "playlist", to: "page#playlist_index", as: :list_index
  get "album/:id", to: "page#album_details", as: :album_details
  get "profile/:username", to: "page#profile", as: :profile
  # Playlist routes
  post "add_album_to_playlist", to: "playlist_albums#create", as: :add_album_to_playlist
  post "add_song_to_playlist", to: "playlist_songs#create", as: :add_song_to_playlist
  # Admin routes
  get "admin", to: "admin#home", as: :admin_home


  resources :playlists, only: [ :create, :destroy, :edit, :update ] do
    resources :songs, only: [ :destroy ], controller: "playlist_songs"
    # resources :albums, only: [ :create ], controller: "playlist_albums"
  end

  resources :reviews, only: [ :create ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
