require 'test_helper'

class InstallTracking::DeviceUsersControllerTest < ActionController::TestCase
  setup do
    @install_tracking_device_user = install_tracking_device_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:install_tracking_device_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install_tracking_device_user" do
    assert_difference('InstallTracking::DeviceUser.count') do
      post :create, install_tracking_device_user: @install_tracking_device_user.attributes
    end

    assert_redirected_to install_tracking_device_user_path(assigns(:install_tracking_device_user))
  end

  test "should show install_tracking_device_user" do
    get :show, id: @install_tracking_device_user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @install_tracking_device_user.to_param
    assert_response :success
  end

  test "should update install_tracking_device_user" do
    put :update, id: @install_tracking_device_user.to_param, install_tracking_device_user: @install_tracking_device_user.attributes
    assert_redirected_to install_tracking_device_user_path(assigns(:install_tracking_device_user))
  end

  test "should destroy install_tracking_device_user" do
    assert_difference('InstallTracking::DeviceUser.count', -1) do
      delete :destroy, id: @install_tracking_device_user.to_param
    end

    assert_redirected_to install_tracking_device_users_path
  end
end
