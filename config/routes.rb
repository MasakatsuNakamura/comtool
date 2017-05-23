Rails.application.routes.draw do
  resources :database_manages, only: :show do
    member do
      get 'sign_csvexport'
      get 'sign_binexport'
      get 'config_csvexport'
      get 'config_binexport'
      get 'restore'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'static_pages#welcome'
  get 'welcome', to: 'static_pages#welcome'
  get 'about',   to: 'static_pages#about'
  get 'help',    to: 'static_pages#help'
  get 'signup',  to: 'users#new'
  get 'signin',  to: 'sessions#new'
  delete 'signout', to: 'sessions#destroy'
  resources :users,    except: :destroy
  resources :sessions, only: [:new, :create, :destroy]
  resources :projects, except: :destroy, shallow: true do
    member do
      get 'export_ecuc'
      get 'export_systemdesign'
    end
    resources :modes
    resources :messages, except: :show do
      collection do
        get 'export'
        post 'import'
      end
      member do
        put 'add_signal'
        delete 'del_signal'
      end
    end
  end
end
