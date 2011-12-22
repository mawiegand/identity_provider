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
  
  test "change own profile is possible" do
    num = Identity.count

    post :create, :identity => {
      :nickname   => 'nick3',
      :firstname  => 'Nick',
      :surname    => 'Name',
      :email      => 'email3@web.de',
      :password   => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
    
    identity = Identity.find_by_nickname("nick3")
    
    put :update, :id => identity.id, :identity => {
      :nickname   => 'nick4',
      :firstname  => 'Nick4',
      :surname    => 'Name4',
      :email      => 'email4@web.de',
      :password   => 'password4',
      :password_confirmation => 'password4',
    }
    
    assert_response :redirect 
  end
  
  test "change password with too short passwort is impossible" do
    num = Identity.count

    post :create, :identity => {
      :nickname   => 'nick5',
      :firstname  => 'Nick',
      :surname    => 'Name',
      :email      => 'email5@web.de',
      :password   => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
    
    identity = Identity.find_by_nickname("nick5")
    
    put :update, :id => identity.id, :identity => {
      :nickname   => 'nick6',
      :firstname  => 'Nick6',
      :surname    => 'Name',
      :email      => 'email6@web.de',
      :password   => 'pwd6',
      :password_confirmation => 'pwd6',
    }
    
    assert_response :error 
  end
  
  test "change password with different passowrd_confirmation is impossible" do
    num = Identity.count

    post :create, :identity => {
      :nickname   => 'nick7',
      :firstname  => 'Nick',
      :surname    => 'Name',
      :email      => 'email7@web.de',
      :password   => 'password',
      :password_confirmation => 'password'
    }
    assert_response :redirect
    assert_equal num+1, Identity.count
    
    identity = Identity.find_by_nickname("nick7")
    
    put :update, :id => identity.id, :identity => {
      :nickname   => 'nick8',
      :firstname  => 'Nick8',
      :surname    => 'Name8',
      :email      => 'email8@web.de',
      :password   => 'password8a',
      :password_confirmation => 'password8b',
    }
    
    assert_response :error 
  end

end
