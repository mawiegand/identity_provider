require 'test_helper'

class FiveDAccessTokenTest < ActiveSupport::TestCase
  fixtures :all

  test "creates valid tokens" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
    assert access_token.valid?
    assert_not access_token.malformed?
    assert_not access_token.in_future?
    assert_not access_token.expired?
    
    access_token2 = FiveDAccessToken.new access_token.token
    assert access_token2.valid?
    assert_not access_token2.malformed?
    assert_not access_token2.in_future?
    assert_not access_token2.expired?
  end

  test "unwrapping and wrapping does not change token" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
    access_token2 = FiveDAccessToken.new access_token.token
    assert_equal access_token.token, access_token2.token
  end
  
  test "can extract information" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
    assert_equal 'identifier', access_token.identifier
    assert access_token.in_scope?('test')
    assert access_token.in_scope?('scope')
    assert access_token.in_scope?('SCOPE')
    assert_not access_token.in_scope?('sco')
  end
  
  test "change of information or signature are noticed" do
    access_token = FiveDAccessToken.generate_access_token('identifier', ['test', 'scope'])
 
    str = access_token.token
    str[4] = 'c'
    access_token2 = FiveDAccessToken.new str
    assert_not access_token2.valid?
    
    str = access_token.token
    str[str.length-4] = 'c'
    access_token2 = FiveDAccessToken.new str
    assert_not access_token2.valid?    
  end
  
end
