Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post '/signup', to: 'users#create'
      post '/login', to: 'auth#create'
      get '/profile', to: 'users#profile'
      get '/persist', to: 'auth#show'
      get '/customer-groups', to: 'square#customers'
    end
  end
end
