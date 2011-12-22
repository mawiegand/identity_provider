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
      :login => identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    
    get "/identities"
    assert_response :redirect
    
    get "/log_entries"
    assert_response :redirect
  end

  test "deleted user can not log in" do
    identity = identities(:deleted)
    
    post_via_redirect "/sessions", :session => { 
      :login => identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    assert_not_nil flash[:error]
  end

  test "staff can not access admin pages" do
  end
  
  test "staff can access staff pages" do
    identity = identities(:staff)
    
    post_via_redirect "/sessions", :session => { 
      :login => identity.email, 
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
      :login => identity.email, 
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
  
  test "change other profile by staff is possible" do
    staff_identity = identities(:staff)
    
    post_via_redirect "/sessions", :session => { 
      :login => staff_identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    
    user_identity = identities(:user)
        
    put "/identities/" + user_identity.id.to_s, :identity => {
      :nickname   => 'nick',
      :firstname  => 'Nick',
      :surname    => 'Name',
      :email      => 'email8@web.de',
      :password   => 'password',
      :password_confirmation => 'password',
    }
    
    assert_response :redirect
  end
 
  test "change other profile by non-staff user is impossible" do
    user_identity = identities(:user)
    
    post_via_redirect "/sessions", :session => { 
      :login => user_identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"
    
    other_user_identity = identities(:other_user)
        
    put "/identities/" + other_user_identity.id.to_s, :identity => {
      :nickname   => 'nick',
      :firstname  => 'Nick',
      :surname    => 'Name',
      :email      => 'email8@web.de',
      :password   => 'password',
      :password_confirmation => 'password',
    }
    
    assert_response :error
  end
 
end
