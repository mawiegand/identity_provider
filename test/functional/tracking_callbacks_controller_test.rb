require 'test_helper'

class TrackingCallbacksControllerTest < ActionController::TestCase
  setup do
    @tracking_callback = tracking_callbacks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tracking_callbacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tracking_callback" do
    assert_difference('TrackingCallback.count') do
      post :create, tracking_callback: @tracking_callback.attributes
    end

    assert_redirected_to tracking_callback_path(assigns(:tracking_callback))
  end

  test "should show tracking_callback" do
    get :show, id: @tracking_callback.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tracking_callback.to_param
    assert_response :success
  end

  test "should update tracking_callback" do
    put :update, id: @tracking_callback.to_param, tracking_callback: @tracking_callback.attributes
    assert_redirected_to tracking_callback_path(assigns(:tracking_callback))
  end

  test "should destroy tracking_callback" do
    assert_difference('TrackingCallback.count', -1) do
      delete :destroy, id: @tracking_callback.to_param
    end

    assert_redirected_to tracking_callbacks_path
  end
end
