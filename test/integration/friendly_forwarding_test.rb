require 'test_helper'

class FriendlyForwardingTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "should forward to the requested page after signin" do
  
    identity = identities(:admin)
    
    
    get identities_path
    assert redirect?
    follow_redirect!
    assert_template :new
    
    post sessions_path, :session => { 
      :login => identity.email, 
      :password => "sonnen"
    }
    assert redirect?
    assert_redirected_to identities_path
   
  
  end
end
