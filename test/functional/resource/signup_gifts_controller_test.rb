require 'test_helper'

class Resource::SignupGiftsControllerTest < ActionController::TestCase
  setup do
    @resource_signup_gift = resource_signup_gifts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_signup_gifts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_signup_gift" do
    assert_difference('Resource::SignupGift.count') do
      post :create, resource_signup_gift: @resource_signup_gift.attributes
    end

    assert_redirected_to resource_signup_gift_path(assigns(:resource_signup_gift))
  end

  test "should show resource_signup_gift" do
    get :show, id: @resource_signup_gift.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_signup_gift.to_param
    assert_response :success
  end

  test "should update resource_signup_gift" do
    put :update, id: @resource_signup_gift.to_param, resource_signup_gift: @resource_signup_gift.attributes
    assert_redirected_to resource_signup_gift_path(assigns(:resource_signup_gift))
  end

  test "should destroy resource_signup_gift" do
    assert_difference('Resource::SignupGift.count', -1) do
      delete :destroy, id: @resource_signup_gift.to_param
    end

    assert_redirected_to resource_signup_gifts_path
  end
end
