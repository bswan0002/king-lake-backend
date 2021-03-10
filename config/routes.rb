Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post '/signup', to: 'users#create'
      post '/login', to: 'auth#create'
      post '/orders', to: 'orders#create'
      post '/commit-adjustments', to: 'commit_adjustments#create'
      post '/events', to: 'events#create'
      get '/commit-adjustments', to: 'commit_adjustments#index'
      get '/commit-adjustments/:id', to: 'commit_adjustments#show'
      delete '/commit-adjustments/:id', to: 'commit_adjustments#destroy'
      get '/events', to: 'events#index'
      get '/orders', to: 'orders#index'
      get '/orders/:id', to: 'orders#show'
      patch '/orders/:id', to: 'orders#update'
      get '/profile', to: 'users#profile'
      get '/persist', to: 'auth#show'
      get '/all-customers', to: 'square#customers'
      get '/wines', to: 'square#wines'
      get '/members/:id', to: 'square#show'
    end
  end
end
