require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "logged-out user is redirected to sign in when accessing staff pages" do
    get "/identities"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "new"   
  end
  
  test "can not access non-public pages as standard user" do
    identity = identities(:user)
    
    post_via_redirect "/sessions", :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    
    get "/identities"
    assert_response :redirect
    
    get "/log_entries"
    assert_response :redirect
  end

  test "staff can not access admin pages" do
  end
  
  test "staff can access staff pages" do
    identity = identities(:staff)
    
    post_via_redirect "/sessions", :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    
    get "/identities"
    assert_response :success
    assert_template "index"
    
    get "/log_entries"
    assert_response :success
    assert_template "index"
  end

  test "admin can access staff pages" do
    identity = identities(:admin)
    
    post_via_redirect "/sessions", :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    
    get "/identities"
    assert_response :success
    assert_template "index"
  end

  test "admin can access admin pages" do
  end
  
  
end
