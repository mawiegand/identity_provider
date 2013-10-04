IdentityProvider::Application.routes.draw do

  # all resources and paths are scoped in an optional path_prefix determining the
  # locale to use. Presently only available: en, de

  scope "/identity_provider" do
    scope "(:locale)", :locale => /en|de/ do   
      match '/identities/self', :to => 'identities#self'
      
      resource  :dashboard,             :controller => "Dashboard", :only => [:show, :create]
      
      resources :identities,    :only => [:new, :create, :show, :index, :edit, :destroy, :update] do
        resources :messages 
        resources :facebook,    :only => [:update]
      end
      
      resources :game_center, :only => [:show, :update]
      resources :facebook,    :only => [:show, :update]
      
      resources :sessions,    :only => [:new, :create, :destroy]
      resources :log_entries, :only => [:index]
      resources :clients
      resources :granted_scopes
      resources :keys
      resources :client_names
      resources :client_releases
      
      resources :redirects
      match '/redirect_to', :to => 'redirects#redirect'
      

      resources :signup_gifts,          :path => "identities/:identity_id/signup_gifts",          :module => 'resource'                  
      resources :character_properties,  :path => "identities/:identity_id/character_properties",  :module => 'resource'            
      resources :results,               :path => "identities/:identity_id/results",               :module => 'resource'            
      resources :histories,             :path => "identities/:identity_id/histories",             :module => 'resource'            
  
      resources :messages
  
  
      namespace :install_tracking do 
        resources :install_users
        resources :device_users
        resources :installs
        resources :devices 
        resources :tracking_events
        resources :push_notification_tokens
      end
      
      namespace :resource do 
        resources :character_properties
        resources :results
        resources :histories
        resources :games 
        resources :signups
        resources :waiting_lists
        resources :signup_gifts
      end
      
      namespace :game do 
        resources :scheduled_game_downtimes 
        resources :scheduled_server_downtimes
        resources :game_instances
        resources :servers
        resources :game_instances 
      end

      namespace :shop do
        resources :fb_payments_logs, :defaults => { :format => 'text' }
      end

      namespace :stats do
        resource :overview, :controller => :overview
        resources :money_transactions
      end
      
      namespace :oauth2 do
        match :access_token,    :to => 'access_tokens#create'
        match :fb_access_token, :to => 'fb_access_tokens#create'
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

      match '/shop/callback',       :to => 'shop/callback#redirect'

    end
   
    match '/:locale' => 'sessions#new'         # match e.g. /de/
    root :to => 'sessions#new'                 # redirect to signin
  end

  # See how all your routes lay out with "rake routes"
end
