require 'base64'
require 'digest'
require 'json'

  # Represents an access token issued by the identity provider. This class
  # is optimized for validating a given access token string and extracting
  # it's contents, since this use case will occure more often than 
  # constructing a new access token for a given identifier. 
  #
  # Usage to validate :
  #  accessToken = FiveDAccessToken.new string_sent_from_client 
  #  accessToken.valid? && !accessToken.expired?   # => true in case it's usable
  # Before you grant access to a resource, you should always check both,
  # that the access token is valid and has not been expired!
  #
  # Usage to generate a new token for the user identifier 'xyz' and scope 
  # '5dentity':
  #  accessToken = FiveDAccessToken.generate_access_token('xyz', ['5dentity'])
  #  accessToken.token   # => signed and b64-encoded access token string to be send to client
  class FiveDAccessToken 
    
    @@shared_secret = 'ARandomStringWithGoodEntropy'
    @@expiration    = 3600                 # expiration in seconds
    
    # generates a new access token for the given identifier and scope
    #
    #  accessToken = FiveDAccessToken.generate_access_token('user-identifier-string', ['5dentity, 'wackadoo'])
    def self.generate_access_token(identifier, scope)
      return FiveDAccessToken.new FiveDAccessToken.calc_token(identifier, scope, Time.now)
    end
    
    # Constructs an AccessToken object for the given access token sent
    # from a client. 
    #
    #   accessToken = FiveDAccessToken.new token-sent-from-client
    def initialize(token_string)
      @token_b64 = token_string            # the token string is in b64, remember it
      @malformed = true and return if token_string.length < 1 # check for empty or too short strings

      @token_str = Base64::decode64 token_string # decode the b64-endocded string

      begin                                # check whether its valid JSON and parse it
        content = JSON.parse @token_str, :max_nesting => 3, :symbolize_names => true
      rescue
        @malformed = true and return       # not JSON, or nested too deeply
      end
      
      # check for presence of necessary information
      @malformed = true and return unless content.has_key?(:token) && content.has_key?(:signature)
      @malformed = true and return unless content[:token].has_key?(:identifier) 
      @malformed = true and return unless content[:token].has_key?(:scope) 
      @malformed = true and return unless content[:token].has_key?(:timestamp) 
      @malformed = true and return unless content[:token].length == 3
  
      content[:token][:timestamp] = Time.parse(content[:token][:timestamp]) # parse time-string to Time object
      
      @token = content[:token]             # store token content
      @signature = content[:signature]     # store signature
    end

    # checks for validity of the token comparing the signature with the content,
    # checking for a valid structure and checking that the timestamp is not in the
    # future.
    # 
    #  access_token.valid?   # => true, if the token has been signed properly, and the timestamp is not in the future
    def valid?
      return @valid ||= !malformed? && FiveDAccessToken.calc_signature(@token) == @signature && !in_future?
    end
    
    # checks whether or not the access token is already expired by comparing 
    # its timestamp with the present system time.
    #
    #  access_token.expired?  # => true, if the token is to old 
    def expired?
      return Time.now - @token[:timestamp] > @@expiration
    end
    
    # checks whether or not the access token's timestamp is in the future.
    # Has some small tolerance of at least one seconds.
    #
    #  access_token.in_future? # => true, if the timestamp is in the future
    def in_future?
      return (@token[:timestamp] <=> Time.now) > 1   # 1 second tolerance
    end
    
    # returns true in case the given access token could not be parsed 
    # because it had an unkonwn structure or was missing some content.
    #
    #  access_token.malformed?  # => true, if something went wrong trying to parse the access token
    def malformed?
      return @malformed
    end

    # returns the signed and b64-encoded token that should be sent to the client.
    def token
      return @token_b64
    end

    # returns the identifier for which this token was issued. Trustworthy.
    def identifier
      return @token[:identifier]
    end    
    
    # returns the scope-array for which this token was issued. Trustworthy.
    def scope
      return @token[:scope]
    end
    
    # returns true, in case the given scope is inside the access_tokens scope
    # and false otherwise. 
    #
    #  access_token.in_scope?('5dentity') # true: access token authorizes access to 5dentity 
    def in_scope?(scope)
      return @token[:scope].include?(scope)
    end
    
    protected
    
      def self.calc_token(identifier, scope, timestamp)
        strb64 = Base64.encode64(FiveDAccessToken.calc_token_string identifier, scope, timestamp)
        return strb64.gsub(/[\n\r ]/,'')  # remove line breaks and spaces
      end
    
      def self.calc_token_string(identifier, scope, timestamp)
        token_content = {
          :identifier => identifier,
          :scope => scope,
          :timestamp => timestamp
        }
                
        signature = FiveDAccessToken.calc_signature(token_content)
        return { :token => token_content, :signature => signature }.to_json
      end
      
      def self.calc_signature(token)
        return Digest::SHA1.hexdigest("#{token.to_json}.#{@@shared_secret}")
      end

  end
  
  