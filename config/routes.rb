Rails.application.routes.draw do
  get 'database_manages/show'
  get 'database_manages/sign_csvexport'
  get 'database_manages/sign_binexport'
  get 'database_manages/config_csvexport'
  get 'database_manages/config_binexport'
  get 'database_manages/restore'

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
  get 'messages/new'
  get 'messages/export'
  post 'messages/import'
  match 'messages/:id/add_signal(.:format)', to: 'messages#add_signal', via: 'put',    as: 'add_signal'
  match 'messages/:id/del_signal(.:format)', to: 'messages#del_signal', via: 'delete', as: 'del_signal'
  resources :projects, shallow: true do
    get 'export_ecuc', to: 'config#export_ecuc'
    get 'export_systemdesign', to: 'config#export_systemdesign'
  end
end
