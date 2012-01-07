IdentityProvider::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # all resources and paths are scoped in an optional path_prefix determining the
  # locale to use. Presently only available: en, de
  scope "(:locale)", :locale => /en|de/ do   
    resources :identities,  :only => [:new, :create, :show, :index, :edit, :destroy, :update]
    resources :sessions,    :only => [:new, :create, :destroy]
    resources :log_entries, :only => [:index]
    
    namespace :oauth2 do
      resources :access_token, :only => [ :index, :create, :delete ]
    end
        
    match '/signin',  :to => 'sessions#new'
    match '/signout', :to => 'sessions#destroy'

    match '/identities/:id/validation', :to => 'identities#validation'
    
  end
   
  match '/:locale' => 'sessions#new'         # match e.g. /de/
  root :to => 'sessions#new'                 # redirect to signin

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
