Rails.application.routes.draw do
  get 'messages/new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'sessions#new'
  match 'welcome', to: 'static_pages#welcome', via: 'get'
  match 'about',   to: 'static_pages#about',   via: 'get'
  match 'help',    to: 'static_pages#help',    via: 'get'
  match 'signup',  to: 'users#new',            via: 'get'
  match 'signin',  to: 'sessions#new',         via: 'get'
  match 'signout', to: 'sessions#destroy',     via: 'delete'
  resources :users,    only: [:index, :show, :new, :edit, :create, :update]
  resources :sessions, only: [:new, :create, :destroy]
  resources :home,     only: [:index]
  resources :projects, only: [:index, :show, :new, :edit, :create, :update]
  resources :messages, only: [:index, :show, :new, :edit, :create, :update]
end
