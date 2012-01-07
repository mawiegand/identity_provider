require 'json'

# Token Endpoint of the OAuth 2.0 specification.
# Presently only implements the "Resource Owner Password Credentials" Flow.
module Oauth2

  class AccessTokensController < ApplicationController
  
    before_filter :authenticate,    :except => [ :create ]
    before_filter :authorize_staff, :except => [ :create ]
  
    # implementes the POST method endpoint for obtaining an access token
    def create

      body = {
        :access_token => 'myaccesstoken',
        :token_type => 'bearer',
        :expires_in => 3600,
        :refresh_token => 'myrefreshtoken',
        :additional_parameter => 'my_example_value'
      }

      render :status => :ok, :text => JSON.pretty_generate(body)
      headers['Content-Type'] = 'application/x-www-form-urlencoded'
      headers['Cache-Control'] = 'no-store'
      headers['Pragma'] = 'no-cache'
      
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