require 'json'
require 'five_d_access_token'

# Token Endpoint of the OAuth 2.0 specification.
# Presently only implements the "Resource Owner Password Credentials" Flow.
module Oauth2

  # This controller implements an access token endpoint according to the specifications
  # of OAuth 2.0 as well as a basic administration interface, to list, inspect and
  # revoke individual grants (basically to revoke refresh tokens). 
  class FbAccessTokensController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [ :create, :redirect_test_start, :redirect_test_end ] # this prevents setting a session key on a post to the access token endpoint
      
    @@default_scope    = IDENTITY_PROVIDER_CONFIG['default_scope']    || ['5dentity']
    @@token_expiration = IDENTITY_PROVIDER_CONFIG['token_expiration'] || 3600
      
    # Implementes the POST method endpoint for obtaining an access token from our facebook app.
    def create
                      
      logger.debug('Request for fb-access-token with params: ' + params.inspect)
      logger.debug(IDENTITY_PROVIDER_CONFIG.inspect)      
            
      # check method; only post allowed
      if !request.post?
        render_endpoint_error params[:client_id], :invalid_request, "This endpoint only supports POST. " +
          "Your request used HTTP #{ request.method }.";
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
      elsif (params[:grant_type].downcase != 'fb-player-id') 
        render_endpoint_error params[:client_id], :unsupported_grant_type, "This endpoint only supports the following "+
          "grant types: fb-player-id. Please use one of those.";
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
      if params[:fb_player_id].blank?
        render_endpoint_error params[:client_id], :invalid_request, "The request is missing the fb_player_id."
        return 
      end
      
      if params[:fb_access_token].blank?
        logger.error "DEPRECATION WARNING: fb_access_token missing in request. Due to the security risks, sending it will soon become a must."
      end
      
      
      
      
      # 3 methods for authentication:
      # a) generic users may be authenticated just by sending the device token  (we trust them)
      # b) game-center connected users may be authenticated just by sending the game center id  (we trust the installed app)
      # c) portable users are authenticated by sending username or email AND password
      
      identity = if !(params[:fb_player_id]).blank?
        ident = Identity.find_by_fb_player_id(params[:fb_player_id])                      # no authentication for game-center....
     
        if ident.nil?  # signup player
          agent       = request.env["HTTP_USER_AGENT"]
          referer     = request.env["HTTP_X_ALT_REFERER"]
          request_url = request.env["HTTP_X_ALT_REQUEST"]

          logger.debug "Trying to signup facebook user with user agent #{agent}, referer #{referer} and request url #{request_url}."

          LogEntry.create_signup_attempt(params, current_identity, request.remote_ip, agent, referer, request_url)
          if params[:fb_access_token].blank?
            ident = Identity.create_with_fb_player_id_and_client(params[:fb_player_id], client)
          else
            ident = Identity.create_with_fb_player_id_access_token_and_client(params[:fb_player_id] ,params[:fb_access_token],  client)
          end
        end
  
        ident
      else
        nil
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
      LogEntry.create_auth_token_success(params[:fb_player_id], identity, params[:client_id], request.remote_ip)

      # SERVER-SIDE FIX for Android bug: fill device_token with advertiser token, iff empty!
      begin
        if !params[:device_information].nil?
          if params[:device_information][:device_token].blank? 
            if !params[:device_information][:operating_system].nil? && params[:device_information][:operating_system].include?('ndroid')
              params[:device_information][:device_token] = params[:device_information][:advertiser_token]
            end
          end
        end
      rescue
        logger.error "ERROR: Server-side fix for empty device_token on Android did cause an exception."
      end
      # END SERVER-SIDE FIX

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
    
      
    protected
      
      def render_endpoint_error(client_id, error_code, error_description = nil, error_uri = nil)

        body = {
          :error             => error_code,   # invalid_client, invalid_grant, unauthorized_client, unsupported_grant_type, invalid_scope
          :error_description => error_description,
          :error_uri         => error_uri
        }
        
        LogEntry.create_auth_token_failure(params[:fb_player_id], current_identity, params[:client_id], error_code, error_description, request.remote_ip)

        if (!request.post? && !params[:callback].blank?) # JSONP
          render :status => :bad_request, :json => JSON.pretty_generate(body.delete_if { |k,v| v.blank? }), :callback => params[:callback]
        else
          render :status => :bad_request, :json => JSON.pretty_generate(body.delete_if { |k,v| v.blank? })
        end
        headers['Cache-Control'] = 'no-store'
        headers['Pragma'] = 'no-cache'
        headers['Connection'] = 'close'
        
        logger.info("FBAuth #{ error_code.to_s } error for client #{ client_id } from #{ request.remote_ip }: #{ error_description }")
        
        # NOTE: add to tests:
        # does include an error attribute with a valid error code
        # check cache control no-store
        # check pragma no-cache
        # check Content-Type is application/json;charset=UTF-8   
      end
  
  end

end