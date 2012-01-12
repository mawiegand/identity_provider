require 'test_helper'

class FiveDAccessTokenTest < ActiveSupport::TestCase
  fixtures :all

  test "creates valid tokens" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
    assert access_token.valid?, "Newly created access token is not valid."
    assert !access_token.malformed?, "Newly created access token is malformed."
    assert !access_token.in_future?, "Newly created access token has been issued in the future."
    assert !access_token.expired?, "Newly created access token is already expired."
    
    access_token2 = FiveDAccessToken.new access_token.token
    assert access_token2.valid?, "Token string produces an invalid access token."
    assert !access_token2.malformed?, "Token string produces a malformed access token."
    assert !access_token2.in_future?, "Token string produces an access token that has been issued in the future."
    assert !access_token2.expired?, "Token string produces an already expired access token."
  end

  test "unwrapping and wrapping does not change token" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
    access_token2 = FiveDAccessToken.new access_token.token
    assert_equal access_token.token, access_token2.token
  end
  
  test "can extract information" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
    assert_equal 'identifier', access_token.identifier, "Can not extract correct user identifier."
    assert access_token.in_scope?('test'), "Missing first scope element."
    assert access_token.in_scope?('scope'), "Missing second scope element."
    assert access_token.in_scope?('SCOPE'), "Scope checking is not case insensitive."
    assert !access_token.in_scope?('sco'), "Contains invalid scope."
  end
  
  test "change of information or signature are noticed" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
 
    str = access_token.token
    str[4] = 'c'
    access_token2 = FiveDAccessToken.new str
    assert !access_token2.valid?
    
    str = access_token.token
    str[str.length-4] = 'c'
    access_token2 = FiveDAccessToken.new str
    assert !access_token2.valid?    
  end
  
end
