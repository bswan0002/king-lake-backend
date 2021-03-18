Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :commit_adjustments, only: [:index, :show, :create, :destroy]
      resources :events, only: [:index, :create, :update, :destroy]
      resources :orders, only: [:index, :show, :create, :update]
      get '/profile', to: 'users#profile'
      get '/persist', to: 'auth#show'
      get '/all-customers', to: 'square#customers'
      get '/wines', to: 'square#wines'
      get '/members/:id', to: 'square#show'
      post '/signup', to: 'users#create'
      post '/login', to: 'auth#create'
    end
  end
end
