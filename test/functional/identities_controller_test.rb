require 'test_helper'
require 'sessions_helper'

class IdentitiesControllerTest < ActionController::TestCase

  test "no unauthorized access to index" do
    get :index
    assert_response :redirect    
    assert_redirected_to signin_path
  end
  
  test "signup is possible" do 
    num = Identity.count
    
    post :create, :identity => {
      :nickname => "nick",
      :email    => 'email@web.de',
      :password => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
  end

  test "signup without nick is possible" do 
    # first user without nick
    num = Identity.count
    
    post :create, :identity => {
      :email    => 'email@web.de',
      :password => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
    
    
    # second user without nick is ok
    num = Identity.count
    
    post :create, :identity => {
      :email    => 'email2@web.de',
      :password => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
  end
  
  
  test "signup with non-unique nick is not possible" do 
    # first user with nick
    num = Identity.count
    
    post :create, :identity => {
      :nickname => 'nick',
      :email    => 'email@web.de',
      :password => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
    
    
    # second user with same nick is not ok
    num = Identity.count
    
    post :create, :identity => {
      :nickname => 'nick',
      :email    => 'email2@web.de',
      :password => 'password',
      :password_confirmation => 'password'
    }
    assert_response :success
    assert_equal num, Identity.count
  end


end
