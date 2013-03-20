require 'test_helper'

class InstallTracking::DevicesControllerTest < ActionController::TestCase
  setup do
    @install_tracking_device = install_tracking_devices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:install_tracking_devices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install_tracking_device" do
    assert_difference('InstallTracking::Device.count') do
      post :create, install_tracking_device: @install_tracking_device.attributes
    end

    assert_redirected_to install_tracking_device_path(assigns(:install_tracking_device))
  end

  test "should show install_tracking_device" do
    get :show, id: @install_tracking_device.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @install_tracking_device.to_param
    assert_response :success
  end

  test "should update install_tracking_device" do
    put :update, id: @install_tracking_device.to_param, install_tracking_device: @install_tracking_device.attributes
    assert_redirected_to install_tracking_device_path(assigns(:install_tracking_device))
  end

  test "should destroy install_tracking_device" do
    assert_difference('InstallTracking::Device.count', -1) do
      delete :destroy, id: @install_tracking_device.to_param
    end

    assert_redirected_to install_tracking_devices_path
  end
end
