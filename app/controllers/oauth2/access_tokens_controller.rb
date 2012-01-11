require 'json'
require 'five_d_access_token'

# Token Endpoint of the OAuth 2.0 specification.
# Presently only implements the "Resource Owner Password Credentials" Flow.
module Oauth2

  class AccessTokensController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [ :create ] # this prevents setting a session key on a post to the access token endpoint
  
    before_filter :authenticate,    :except => [ :create ]
    before_filter :authorize_staff, :except => [ :create ]
      
    # implementes the POST method endpoint for obtaining an access token
    def create
      client_id     = 'XYZ'
      client_secret = 'passwd'
      client_allowed_grant_types = [ 'password' ]
      client_scope  = [ '5dentity', 'wackadoo' ]
      default_scope = ['5dentity']
                      
      logger.debug('Request for access-token with params: ' + params.inspect)
            
      # check method; only post allowed
      if (!request.post?)
        render_endpoint_error params[:client_id], :invalid_request, "This endpoint only supports POST. " +
          "Your request used HTTP #{ request.method }.";
        return 
      end
      
      # check encoding
      if (request.content_type() != "application/x-www-form-urlencoded")
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
      elsif params[:client_id].split('-')[0] != client_id
        render_endpoint_error params[:client_id], :invalid_client, "This client is unknown.";
        return
      elsif !client_allowed_grant_types.include? params[:grant_type].downcase       
        render_endpoint_error params[:client_id], :unauthorized_client, "This client is not authorized to use the " +
          "requested authorization grant type.";
        return
      end

      # check scope or set to default
      if !params[:scope] 
        @scope = default_scope
      else
        requested_scopes = params[:scope].split(' ')

        if requested_scopes.empty?
          @scope = default_scope
        else 
          if requested_scopes.any? { |rscope| !client_scope.include? rscope } # unauthorized scope
            render_endpoint_error params[:client_id], :invalid_scope, "The requested scope is invalid, unknown, malformed, or "+
              "exceeds the scope granted by the resource owner."
            return
          else
            @scope = requested_scopes
          end
        end
      end     
      
      # check username and password
      if params[:username].blank? || params[:password].blank?
        render_endpoint_error params[:client_id], :invalid_request, "The request is missing the username and / or password."
        return 
      end
      
      identity = Identity.authenticate(params[:username], params[:password])
      if !identity
        render_endpoint_error params[:client_id], :invalid_grant, "Invalid resource owner credentials."
        return 
      end
        
      access_token = FiveDAccessToken.generate_access_token(identity.identifier, @scope)
      if !access_token || !access_token.valid? || access_token.expired?
        logger.error('OAuth2 : failed to create a valid access token for an otherwise valid request.')
        render_endpoint_error params[:client_id], :invalid_grant, 'Could not crate a valid access token for unkown reasons. Please contact the support staff.'
        return
      end
      
      if true      # on success
        body = {
          :access_token => access_token.token,
          :token_type => 'bearer',
          :expires_in => 3600,
#         :refresh_token => 'myrefreshtoken',
          :user_identifer => identity.identifier
        }

        render :status => :ok, :json => JSON.pretty_generate(body)
        headers['Cache-Control'] = 'no-store'
        headers['Pragma'] = 'no-cache'
        headers['Connection'] = 'close'

        # NOTE: add to tests:
        # check cache control no-store
        # check pragma no-cache
        # check Content-Type is application/json;charset=UTF-8   (compare case-insensitve, remove whitespaces)

     end
       
      
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

        render :status => :bad_request, :json => JSON.pretty_generate(body.delete_if { |k,v| v.blank? })
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