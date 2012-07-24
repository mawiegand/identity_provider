IdentityProvider::Application.routes.draw do

  namespace :resource do resources :results end

  namespace :resource do resources :histories end

  namespace :resource do resources :games end

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
  scope "/identity_provider" do
    scope "(:locale)", :locale => /en|de/ do   
      match '/identities/self', :to => 'identities#self'
      
      resources :identities,  :only => [:new, :create, :show, :index, :edit, :destroy, :update]
      resources :sessions,    :only => [:new, :create, :destroy]
      resources :log_entries, :only => [:index]
      resources :clients
      resources :granted_scopes
      resources :keys
      
      
      namespace :oauth2 do
        match :access_token, :to => 'access_tokens#create'
        match :redirect_test_start, :to => 'access_tokens#redirect_test_start'
        match :redirect_test_end,   :to => 'access_tokens#redirect_test_end'
        resources :access_tokens,   :only => [ :index, :show, :delete ] # routes for administering issued access tokens
      end
          
      match '/signin',  :to => 'sessions#new'
      match '/signout', :to => 'sessions#destroy'
  
      match '/identities/:id/validation', :to => 'identities#validation'
      match '/identities/:id/signin',     :to => 'identities#signin'
    end
   
    match '/:locale' => 'sessions#new'         # match e.g. /de/
    root :to => 'sessions#new'                 # redirect to signin
  end
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
