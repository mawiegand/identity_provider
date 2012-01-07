# Token Endpoint of the OAuth 2.0 specification.
# Presently only implements the "Resource Owner Password Credentials" Flow.

module Oauth2

  class AccessTokenController < ApplicationController
  
    before_filter :authenticate,    :except => [ :create ]
    before_filter :authorize_staff, :except => [ :create ]
  
    # implementes the POST method endpoint for obtaining an access token
    def create
    end
    
    # enables staff and adminitrators to revoke access tokens
    def destroy
    end
  
    def index
      return 'Generate a list of all handed out access tokens and provide functionallity to revoke individual or all tokens.'
    end
  
  end

end