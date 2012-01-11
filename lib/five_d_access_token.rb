require 'base64'
require 'digest'
require 'json'


  class FiveDAccessToken 
    
    @@shared_secret = 'ARandomStringWithGoodEntropy'
    @@expiration    = 3600                 # expiration in seconds
    
    def self.generate_access_token(identifier, scope)
      return FiveDAccessToken.new FiveDAccessToken.calc_token(identifier, scope, Time.now)
    end
    
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

    def valid?
      return @valid ||= !malformed? && FiveDAccessToken.calc_signature(@token) == @signature && !in_future?
    end
    
    def expired?
      return Time.now - @token[:timestamp] > @@expiration
    end
    
    def in_future?
      return (@token[:timestamp] <=> Time.now) > 0
    end
    
    def malformed?
      return @malformed
    end

    def token
      return @token_b64
    end

    def identifier
      return @token[:identifier]
    end    
    
    def scope
      return @token[:scope]
    end
    
    def in_scope?(sc)
      return @token[:scope].include?(sc)
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
  
  