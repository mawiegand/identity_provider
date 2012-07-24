require 'test_helper'

class Resource::HistoriesControllerTest < ActionController::TestCase
  setup do
    @resource_history = resource_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_history" do
    assert_difference('Resource::History.count') do
      post :create, resource_history: @resource_history.attributes
    end

    assert_redirected_to resource_history_path(assigns(:resource_history))
  end

  test "should show resource_history" do
    get :show, id: @resource_history.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_history.to_param
    assert_response :success
  end

  test "should update resource_history" do
    put :update, id: @resource_history.to_param, resource_history: @resource_history.attributes
    assert_redirected_to resource_history_path(assigns(:resource_history))
  end

  test "should destroy resource_history" do
    assert_difference('Resource::History.count', -1) do
      delete :destroy, id: @resource_history.to_param
    end

    assert_redirected_to resource_histories_path
  end
end
