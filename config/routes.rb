Crm::Application.routes.draw do
  scope '(:locale)' do
    resources :stages, only: [:show]
    
    resources :events do
      post 'add_participant' => 'events#add_participant', as: "add_participant"
      get 'remove_participant/:participant_type/:participant_id' => 'events#remove_participant', as: "remove_participant"
      get 'change_status' => 'events#change_status', as: 'change_status'
      resources :tasks, except: [:index, :show]
      resources :histories, only: [:create, :destroy]      
    end
    
    resources :deals do
      post 'add_participant' => 'deals#add_participant', as: "add_participant"
      get 'remove_participant/:participant_type/:participant_id' => 'deals#remove_participant', as: "remove_participant"
      resources :tasks, except: [:index, :show]
      resources :histories, only: [:create, :destroy]
    end

    resources :tasks, except: [:show]
    
    resources :contacts, only: [:index]
    
    resources :people do
      resources :deals, except: [:index]
      resources :tasks, except: [:index, :show]
      resources :histories, only: [:create, :destroy]
    end
    
    resources :companies do
      post 'add_person' => 'companies#add_person', as: "add_person"
      resources :deals, except: [:index]    
      resources :tasks, except: [:index, :show]
      resources :histories, only: [:create, :destroy]
    end
  
    devise_for :users
    resources :users, only: [:edit, :update]
    get '/profile' => 'users#profile', as: 'profile'
    namespace :admin do
      resources :users
    end
    
    get '/search/(:search)' => 'search#index', as: 'search'
    
    match 'dashboard/index' => "dashboard#index", as: "dashboard"
    
    root :to => 'dashboard#index'
  end
end
