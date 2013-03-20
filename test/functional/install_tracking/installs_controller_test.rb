require 'test_helper'

class InstallTracking::InstallsControllerTest < ActionController::TestCase
  setup do
    @install_tracking_install = install_tracking_installs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:install_tracking_installs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install_tracking_install" do
    assert_difference('InstallTracking::Install.count') do
      post :create, install_tracking_install: @install_tracking_install.attributes
    end

    assert_redirected_to install_tracking_install_path(assigns(:install_tracking_install))
  end

  test "should show install_tracking_install" do
    get :show, id: @install_tracking_install.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @install_tracking_install.to_param
    assert_response :success
  end

  test "should update install_tracking_install" do
    put :update, id: @install_tracking_install.to_param, install_tracking_install: @install_tracking_install.attributes
    assert_redirected_to install_tracking_install_path(assigns(:install_tracking_install))
  end

  test "should destroy install_tracking_install" do
    assert_difference('InstallTracking::Install.count', -1) do
      delete :destroy, id: @install_tracking_install.to_param
    end

    assert_redirected_to install_tracking_installs_path
  end
end
