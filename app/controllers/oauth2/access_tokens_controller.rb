require 'json'

# Token Endpoint of the OAuth 2.0 specification.
# Presently only implements the "Resource Owner Password Credentials" Flow.
module Oauth2

  class AccessTokensController < ApplicationController
  
    before_filter :authenticate,    :except => [ :create ]
    before_filter :authorize_staff, :except => [ :create ]
  
    # implementes the POST method endpoint for obtaining an access token
    def create
      
      if false      # on success
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
      
        # NOTE: add to tests:
        # check cache control no-store
        # check pragma no-cache
        # check Content-Type is application/json;charset=UTF-8   (compare case-insensitve, remove whitespaces)
     else      #  on failure
        body = {
          :error             => 'invalid_request',   # invalid_client, invalid_grant, unauthorized_client, unsupported_grant_type, invalid_scope
          :error_description => 'description of the error for the client DEVELOPER',
          :error_uri         => 'http://www.domain.de/link/to/relevant/developer/documentation'
        }

        render :status => :bad_request, :json => JSON.pretty_generate(body)
        headers['Cache-Control'] = 'no-store'
        headers['Pragma'] = 'no-cache'
        
        # NOTE: add to tests:
        # does include an error attribute with a valid error code
        # check cache control no-store
        # check pragma no-cache
        # check Content-Type is application/json;charset=UTF-8 
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
  
  end

end