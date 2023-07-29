Rails.application.routes.draw do
  root 'chats#index'
  get 'c/:id', to: 'chats#show', as: 'conversation'
  post 'c', to: 'chats#create', as: 'send_message'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  get 'users', to: 'users#index', as: 'users'
  get 'user/:id', to: 'users#show', as: 'profile'
  post 'users/add/:id', to: 'users#add_friend', as: 'add_friend'
  post 'users/accept/:id', to: 'users#accept_request', as: 'accept_request'
  post 'users/cancel/:id', to: 'users#cancel_request', as: 'cancel_request'
  post 'users/unfriend/:id', to: 'users#remove_friend', as: 'remove_friend'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
