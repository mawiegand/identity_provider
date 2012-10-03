require 'test_helper'

class Resource::SignupsControllerTest < ActionController::TestCase
  setup do
    @resource_signup = resource_signups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_signups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_signup" do
    assert_difference('Resource::Signup.count') do
      post :create, resource_signup: @resource_signup.attributes
    end

    assert_redirected_to resource_signup_path(assigns(:resource_signup))
  end

  test "should show resource_signup" do
    get :show, id: @resource_signup.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_signup.to_param
    assert_response :success
  end

  test "should update resource_signup" do
    put :update, id: @resource_signup.to_param, resource_signup: @resource_signup.attributes
    assert_redirected_to resource_signup_path(assigns(:resource_signup))
  end

  test "should destroy resource_signup" do
    assert_difference('Resource::Signup.count', -1) do
      delete :destroy, id: @resource_signup.to_param
    end

    assert_redirected_to resource_signups_path
  end
end
