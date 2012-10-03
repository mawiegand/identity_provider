IdentityProvider::Application.routes.draw do


  # all resources and paths are scoped in an optional path_prefix determining the
  # locale to use. Presently only available: en, de

  scope "/identity_provider" do
    scope "(:locale)", :locale => /en|de/ do   
      match '/identities/self', :to => 'identities#self'
      
      resource  :dashboard,             :controller => "Dashboard", :only => [:show, :create]
      
      resources :identities,  :only => [:new, :create, :show, :index, :edit, :destroy, :update] do
        resources :messages 
      end
      resources :sessions,    :only => [:new, :create, :destroy]
      resources :log_entries, :only => [:index]
      resources :clients
      resources :granted_scopes
      resources :keys
      
      resources :character_properties,  :path => "identities/:identity_id/character_properties",  :module => 'resource'            
      resources :results,               :path => "identities/:identity_id/results",               :module => 'resource'            
      resources :histories,             :path => "identities/:identity_id/histories",             :module => 'resource'            
  
      resources :messages
  
  
      namespace :resource do 
        resources :character_properties
        resources :results
        resources :histories
        resources :games 
        resources :signups
        resources :waiting_lists
        resources :signup_gifts
      end
      
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
  
      match '/send_password_token', :to => 'identities#send_password_token'
      match '/send_password',       :to => 'identities#send_password'
    end
   
    match '/:locale' => 'sessions#new'         # match e.g. /de/
    root :to => 'sessions#new'                 # redirect to signin
  end

  # See how all your routes lay out with "rake routes"
end
