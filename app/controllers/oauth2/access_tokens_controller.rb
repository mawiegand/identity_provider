require 'json'

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
      
      logger.debug('Request for access-token with params: ' + params.inspect)
            
      # check method; only post allowed
      if (!request.post?)
        render_endpoint_error :invalid_request, "This endpoint only supports POST. " +
          "Your request used HTTP #{ request.method }.";
        return 
      end
      
      # check encoding
      if (request.content_type() != "application/x-www-form-urlencoded")
        render_endpoint_error :invalid_request, "The Content-Type of the message must be " +
          "application/x-www-form-urlencoded but was " +
          "#{ ActionController::Base.helpers.sanitize(request.content_type().inspect) }."
        return 
      end
      
      # check grant_type
      if !params[:grant_type] 
        render_endpoint_error :invalid_request, "Your request is missing the grant_type.";
        return 
      elsif (params[:grant_type].downcase != 'password') 
        render_endpoint_error :unsupported_grant_type, "This endpoint only supports the following "+
          "grant types: password. Please use one of those.";
        return 
      end
            
      # check client
      if !params[:client_id] || params[:client_id].blank?
        render_endpoint_error :invalid_request, "Your request is missing the client_id.";
        return
      elsif params[:client_id].split('-')[0] != client_id
        render_endpoint_error :invalid_client, "This client is unknown.";
        return
      end        
        
      # check scope or set to default
      
      # check username
      
      # chek password
      
      if true      # on success
        body = {
          :access_token => 'myaccesstoken',
          :token_type => 'bearer',
          :expires_in => 3600,
          :refresh_token => 'myrefreshtoken',
          :additional_parameter => 'my_example_value'
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
      
      def render_endpoint_error(error_code, error_description = nil, error_uri = nil)

        body = {
          :error             => error_code,   # invalid_client, invalid_grant, unauthorized_client, unsupported_grant_type, invalid_scope
          :error_description => error_description,
          :error_uri         => error_uri
        }

        render :status => :bad_request, :json => JSON.pretty_generate(body.delete_if { |k,v| v.blank? })
        headers['Cache-Control'] = 'no-store'
        headers['Pragma'] = 'no-cache'
        headers['Connection'] = 'close'
        
        # NOTE: add to tests:
        # does include an error attribute with a valid error code
        # check cache control no-store
        # check pragma no-cache
        # check Content-Type is application/json;charset=UTF-8   
      end
  
  end

end