require 'json'
require 'five_d_access_token'

# Token Endpoint of the OAuth 2.0 specification.
# Presently only implements the "Resource Owner Password Credentials" Flow.
module Oauth2

  # This controller implements an access token endpoint according to the specifications
  # of OAuth 2.0 as well as a basic administration interface, to list, inspect and
  # revoke individual grants (basically to revoke refresh tokens). 
  class AccessTokensController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [ :create, :redirect_test_start, :redirect_test_end ] # this prevents setting a session key on a post to the access token endpoint
  
    before_filter :authenticate,    :except => [ :create, :redirect_test_start, :redirect_test_end  ]
    before_filter :authorize_staff, :except => [ :create, :redirect_test_start, :redirect_test_end   ]
    
    @@default_scope    = IDENTITY_PROVIDER_CONFIG['default_scope']    || ['5dentity']
    @@token_expiration = IDENTITY_PROVIDER_CONFIG['token_expiration'] || 3600
      
    # Implementes the POST method endpoint for obtaining an access token.
    # Presently it only implements the 'resource owner password credentials' flow.
    # See the OAuth 2.0 draft specification for further details. 
    #
    # The endpoint can be tested easily using curl, e.g.:
    #  curl -v --data "client_id=XYZ-v0.1&grant_type=password&scope=5dentity%20wackadoo&username=Egbert&password=sonnen" localhost:3000/oauth2/access_token
    # to get an access point for identity Egbert on protected resources in scopes
    # 5dentity and wackadoo. The +client_id+ must be a client identifier of a 
    # known client (has been registered with the identity provider) and may
    # have a version-string for debugging purposes attached, using '-' to 
    # separate it.
    def create
                      
      logger.debug('Request for access-token with params: ' + params.inspect)
      logger.debug(IDENTITY_PROVIDER_CONFIG.inspect)      
            
      # check method; only post allowed
      if !request.post? && !IDENTITY_PROVIDER_CONFIG['allow_jsonp']
        render_endpoint_error params[:client_id], :invalid_request, "This endpoint only supports POST. " +
          "Your request used HTTP #{ request.method }.";
        return 
      end
      
      if (!request.post? && params[:callback].blank?)
        render_endpoint_error params[:client_id], :invalid_request, "This endpoint only supports JSONP via GET. " +
          "Your request used HTTP #{ request.method } but did not send a callback.";
        return 
      end
      
      # check encoding for post requests (don't care for JSONP via GET)
      if (request.post? && request.content_type() != "application/x-www-form-urlencoded")
        render_endpoint_error params[:client_id], :invalid_request, "The Content-Type of the message must be " +
          "application/x-www-form-urlencoded but was " +
          "#{ ActionController::Base.helpers.sanitize(request.content_type().inspect) }."
        return 
      end
      
      # check grant_type
      if !params[:grant_type] 
        render_endpoint_error params[:client_id], :invalid_request, "Your request is missing the grant_type.";
        return 
      elsif (params[:grant_type].downcase != 'password') 
        render_endpoint_error params[:client_id], :unsupported_grant_type, "This endpoint only supports the following "+
          "grant types: password. Please use one of those.";
        return 
      end
            
      # check client
      if !params[:client_id] || params[:client_id].blank?
        render_endpoint_error params[:client_id], :invalid_request, "Your request is missing the client_id.";
        return
      end
      
      client_identifier = params[:client_id]   
      client = Client.find_by_identifier(client_identifier) # get client from database
      
      if !client
        render_endpoint_error params[:client_id], :invalid_client, "This client is unknown.";
        return
      elsif !client.grant_type_allowed? params[:grant_type]       
        render_endpoint_error params[:client_id], :unauthorized_client, "This client is not authorized to use the " +
          "requested authorization grant type.";
        return
      end

      # check whether the requested scopes have been granted to the client requesting authentication
      if !params[:scope] 
        @scope = @@default_scope
      else
        requested_scopes = params[:scope].split(' ')

        if requested_scopes.empty?
          @scope = @@default_scope
        else 
          if requested_scopes.any? { |rscope| !client.scope_authorized?(rscope) } # unauthorized scope
            render_endpoint_error params[:client_id], :invalid_scope, "The requested scope is invalid, unknown, malformed, or "+
              "exceeds the scope granted by the resource owner. In short: the client you're using tried to access the resource in a way it is not allowed to do. Please report this to the support staff."
            return
          else
            @scope = requested_scopes
          end
        end
      end     
      
      #check whether or not the client presently allows sign ins
      if client.signin_mode == Client::SIGNIN_MODE_OFF  
        render_endpoint_error params[:client_id], :invalid_request, "Sign in is disabled at the moment. Please try again later."
        return 
      end
      
      # check username and password
      if (params[:username].blank? || params[:password].blank?) && params[:gc_player_id].blank? && params[:restore_with_device_token].blank?
        render_endpoint_error params[:client_id], :invalid_request, "The request is missing the username and / or password."
        return 
      end
      
      
      # 3 methods for authentication:
      # a) generic users may be authenticated just by sending the device token  (we trust them)
      # b) game-center connected users may be authenticated just by sending the game center id  (we trust the installed app)
      # c) portable users are authenticated by sending username or email AND password
      
      identity = if !(params[:restore_with_device_token]).blank?
        # lookup with device token
        di = params[:device_information] || {}
                
        ident = InstallTracking::Device.find_last_user_on_device_with_token(di[:device_token]) 
        
        # if not found,lookup with new device token
        if !ident && !di[:old_token].blank?
          ident = InstallTracking::Device.find_last_user_on_device_with_token(di[:old_token])
        end
        
        if ident && !ident.partable?
          ident.password              = params[:password]
          ident.password_confirmation = params[:password_confirmation]
          ident.generic_password      = true
          ident.save
        end
        
        ident.portable? ? nil : ident 
      elsif !(params[:gc_player_id]).blank?
        Identity.find_by_gc_player_id(params[:gc_player_id])                      # no authentication for game-center....
      else
        Identity.authenticate(params[:username], params[:password])
      end
      
      if !identity
        render_endpoint_error params[:client_id], :invalid_grant, I18n.translate('error.oauth.wrongCredentials') 
        return 
      end
      
      if identity.banned? 
        render_endpoint_error params[:client_id], :invalid_grant, "User is banned."
        return
      end 
      
      # if the client has the automatic signup feature, grant all missing scopes on the fly
      grants_for_client = identity.grants.where(:client_id => client.id).first
      if grants_for_client.nil? && client.automatic_signup?
        logger.info "Automatic signup for #{identity.email} with client #{client.id} to scopes: #{requested_scopes.inspect}."

#        # already ON waiting list?
#        on_waiting_list = !client.waiting_list_entries.where(identity_id: identity.id).first.nil?
#        if on_waiting_list
#          render_endpoint_error params[:client_id], :invalid_grant, "Du bist bereits auf der Warteliste und solltest eine entsprechende Email erhalten haben."
#          return
#        end

        referer = request.env["HTTP_X_ALT_REFERER"]
        request_url = request.env["HTTP_X_ALT_REQUEST"]
        client.signup_existing_identity(identity, params[:invitation], referer, request_url)

        # put on waiting list?
        on_waiting_list = !client.waiting_list_entries.where(identity_id: identity.id).first.nil?
        if on_waiting_list
          render_endpoint_error params[:client_id], :invalid_grant, "Du wurdest auf der Warteliste platziert und solltest eine Email erhalten."
          return
        end

        grants_for_client = identity.grants.where(:client_id => client.id).first
      end

      # check whether requested scopes were granted to the identity
      logger.debug "Grants the identity has for this client: #{grants_for_client.inspect}"
      logger.debug "Grants the identity requested:           #{requested_scopes.inspect}"
      if requested_scopes.any? { |rscope| grants_for_client.nil? || !grants_for_client.scope_authorized?(rscope) }
        
        if grants_for_client && client.automatic_signup?
          client.extend_grant(grants_for_client)
        end
        
        grants_for_client.reload
        
        if requested_scopes.any? { |rscope| grants_for_client.nil? || !grants_for_client.scope_authorized?(rscope) }
          render_endpoint_error params[:client_id], :invalid_scope, "The requested scope is invalid, unknown, malformed, or "+
                "exceeds the scope granted to the identity. In short: you're not allowed to access the resource. In case of an error, please contact the support staff."
          return
        end
      end
        
      access_token = FiveDAccessToken.generate_access_token(identity.identifier, @scope)
      if !access_token || !access_token.valid? || access_token.expired?
        logger.error('OAuth2 : failed to create a valid access token for an otherwise valid request.')
        render_endpoint_error params[:client_id], :invalid_grant, 'Could not crate a valid access token for unkown reasons. Please contact the support staff.'
        return
      end
      
      logger.debug "Create token that exipres in #{ @@token_expiration } seconds. Time in configuration #{ IDENTITY_PROVIDER_CONFIG['token_expiration']  }."
      
      body = {
        :access_token => access_token.token,
        :token_type => 'bearer',
        :expires_in => @@token_expiration,
        #   :refresh_token => 'myrefreshtoken',
        :user_identifer => identity.identifier
      }
            
      logger.debug "Response Body #{ body.inspect }."
      LogEntry.create_auth_token_success(params[:username], identity, params[:client_id], request.remote_ip)

      if !params[:device_information].nil?
        InstallTracking.handle_install_usage(identity, client, params[:device_information])
      end

      if (!request.post?) # JSONP
        render :status => :ok, :json => JSON.pretty_generate(include_root(body, :access_token)), :callback => params[:callback]
      else
        render :status => :ok, :json => JSON.pretty_generate(include_root(body, :access_token))
      end

      headers['Cache-Control'] = 'no-store'
      headers['Pragma'] = 'no-cache'
      headers['Connection'] = 'close'

      # NOTE: add to tests:
      # check cache control no-store
      # check pragma no-cache
      # check Content-Type is application/json;charset=UTF-8   (compare case-insensitve, remove whitespaces)
      
    end
    
    # hook for client self-check regarding suffering form the lose-header-on-redirect flaw
    def redirect_test_start
      redirect_to :action => :redirect_test_end
    end
    
    def redirect_test_end
      render :json => JSON.pretty_generate({ 
        :authorization_header => request.headers['HTTP_AUTHORIZATION'],
        :accept_header => request.headers['HTTP_ACCEPT'],
        :ok => 
          ! request.headers['HTTP_AUTHORIZATION'].blank? &&
          request.headers['HTTP_AUTHORIZATION'].downcase.start_with?('bearer') &&
          ! request.headers['HTTP_ACCEPT'].blank? &&
          request.headers['HTTP_ACCEPT'] == 'application/json'
      });
    end
    
    # enables staff and adminitrators to revoke access tokens
    def destroy
    end
    
    def show
    end
  
    def index
      return 'Generate a list of all handed out access tokens and provide functionallity to revoke individual or all tokens.'
    end
  
    protected
      
      def render_endpoint_error(client_id, error_code, error_description = nil, error_uri = nil)

        body = {
          :error             => error_code,   # invalid_client, invalid_grant, unauthorized_client, unsupported_grant_type, invalid_scope
          :error_description => error_description,
          :error_uri         => error_uri
        }
        
        LogEntry.create_auth_token_failure(params[:username], current_identity, params[:client_id], error_code, error_description, request.remote_ip)

        if (!request.post? && !params[:callback].blank?) # JSONP
          render :status => :bad_request, :json => JSON.pretty_generate(body.delete_if { |k,v| v.blank? }), :callback => params[:callback]
        else
          render :status => :bad_request, :json => JSON.pretty_generate(body.delete_if { |k,v| v.blank? })
        end
        headers['Cache-Control'] = 'no-store'
        headers['Pragma'] = 'no-cache'
        headers['Connection'] = 'close'
        
        logger.info("OAuth2 #{ error_code.to_s } error for client #{ client_id } from #{ request.remote_ip }: #{ error_description }")
        
        # NOTE: add to tests:
        # does include an error attribute with a valid error code
        # check cache control no-store
        # check pragma no-cache
        # check Content-Type is application/json;charset=UTF-8   
      end
  
  end

end