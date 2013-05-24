require 'test_helper'

class InstallTracking::PushNotificationTokensControllerTest < ActionController::TestCase
  setup do
    @install_tracking_push_notification_token = install_tracking_push_notification_tokens(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:install_tracking_push_notification_tokens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install_tracking_push_notification_token" do
    assert_difference('InstallTracking::PushNotificationToken.count') do
      post :create, install_tracking_push_notification_token: @install_tracking_push_notification_token.attributes
    end

    assert_redirected_to install_tracking_push_notification_token_path(assigns(:install_tracking_push_notification_token))
  end

  test "should show install_tracking_push_notification_token" do
    get :show, id: @install_tracking_push_notification_token.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @install_tracking_push_notification_token.to_param
    assert_response :success
  end

  test "should update install_tracking_push_notification_token" do
    put :update, id: @install_tracking_push_notification_token.to_param, install_tracking_push_notification_token: @install_tracking_push_notification_token.attributes
    assert_redirected_to install_tracking_push_notification_token_path(assigns(:install_tracking_push_notification_token))
  end

  test "should destroy install_tracking_push_notification_token" do
    assert_difference('InstallTracking::PushNotificationToken.count', -1) do
      delete :destroy, id: @install_tracking_push_notification_token.to_param
    end

    assert_redirected_to install_tracking_push_notification_tokens_path
  end
end
