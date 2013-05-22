require 'test_helper'

class InstallTracking::TrackingEventsControllerTest < ActionController::TestCase
  setup do
    @install_tracking_tracking_event = install_tracking_tracking_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:install_tracking_tracking_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install_tracking_tracking_event" do
    assert_difference('InstallTracking::TrackingEvent.count') do
      post :create, install_tracking_tracking_event: @install_tracking_tracking_event.attributes
    end

    assert_redirected_to install_tracking_tracking_event_path(assigns(:install_tracking_tracking_event))
  end

  test "should show install_tracking_tracking_event" do
    get :show, id: @install_tracking_tracking_event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @install_tracking_tracking_event.to_param
    assert_response :success
  end

  test "should update install_tracking_tracking_event" do
    put :update, id: @install_tracking_tracking_event.to_param, install_tracking_tracking_event: @install_tracking_tracking_event.attributes
    assert_redirected_to install_tracking_tracking_event_path(assigns(:install_tracking_tracking_event))
  end

  test "should destroy install_tracking_tracking_event" do
    assert_difference('InstallTracking::TrackingEvent.count', -1) do
      delete :destroy, id: @install_tracking_tracking_event.to_param
    end

    assert_redirected_to install_tracking_tracking_events_path
  end
end
