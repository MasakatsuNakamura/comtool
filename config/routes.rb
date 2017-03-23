Rails.application.routes.draw do
  get 'messages/new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'static_pages#welcome'
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
  resources :messages, only: [:index, :new, :edit, :create, :update, :destroy]
  match 'messages/:id/add_signal(.:format)', to: 'messages#add_signal', via: 'put',    as: 'add_signal'
  match 'messages/:id/del_signal(.:format)', to: 'messages#del_signal', via: 'delete', as: 'del_signal'
  resources :projects, shallow: true do
    get 'export', to: 'config#export'
    post 'export', to: 'config#export'
  end
end
