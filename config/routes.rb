Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post '/signup', to: 'users#create'
      post '/login', to: 'auth#create'
      post '/orders', to: 'orders#create'
      get '/orders', to: 'orders#index'
      get '/orders/:id', to: 'orders#show'
      get '/profile', to: 'users#profile'
      get '/persist', to: 'auth#show'
      get '/all-customers', to: 'square#customers'
      get '/wines', to: 'square#wines'
      get '/members/:id', to: 'square#show'
    end
  end
end
