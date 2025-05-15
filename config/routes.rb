Rails.application.routes.draw do

  post '/log_action', to: 'hotels#log_action'
  # post "/log_action", to: "actions#log"
  
  devise_for :users, controllers: {
  sessions: 'users/sessions'
  }

  resources :hotels, only: [:index, :show] do
    collection do
      get :search
    end
    resources :reviews, only: [:create, :destroy]
  end

  resources :reservations, only: [:new, :create, :destroy]

  resources :reservations do
    resource :payment, only: [:show, :create]
  end
  
  post "/stripe/webhooks", to: "stripe_webhooks#create"

  root "hotels#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get '/profile', to: 'users#profile', as: :profile
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
