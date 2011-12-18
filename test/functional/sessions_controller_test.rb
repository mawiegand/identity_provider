require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :all
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "can log in" do
    identity = identities(:user)

    post :create, :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }
    assert_response :redirect
    assert_redirected_to identity

    assert_equal identity.id, @controller.current_identity.id
    assert @controller.signed_in?
  end
  
  test "can not log in with wrong password" do
    identity = identities(:user)

    post :create, :session => { 
      :email => identity.email, 
      :password => "falsch"
    }
    assert_response :success
    assert_template 'new'
    assert_nil @controller.current_identity
    assert !@controller.signed_in?
  end
  
  test "visitors have the correct role" do   
    assert !@controller.signed_in?
    assert !@controller.staff?
    assert !@controller.admin?
  end
  
  test "standard users have the correct role" do
    identity = identities(:user)

    post :create, :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }   
    assert @controller.signed_in?
    assert !@controller.staff?
    assert !@controller.admin?
  end

  test "staff users have the correct role" do
    identity = identities(:staff)

    post :create, :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }   
    assert @controller.signed_in?
    assert @controller.staff?
    assert !@controller.admin?
  end
  
  test "admin users have the correct role" do
    identity = identities(:admin)

    post :create, :session => { 
      :email => identity.email, 
      :password => "sonnen"
    }   
    assert @controller.signed_in?
    assert @controller.staff?
    assert @controller.admin?
  end

end
