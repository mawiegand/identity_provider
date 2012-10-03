require 'test_helper'

class Resource::WaitingListsControllerTest < ActionController::TestCase
  setup do
    @resource_waiting_list = resource_waiting_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_waiting_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_waiting_list" do
    assert_difference('Resource::WaitingList.count') do
      post :create, resource_waiting_list: @resource_waiting_list.attributes
    end

    assert_redirected_to resource_waiting_list_path(assigns(:resource_waiting_list))
  end

  test "should show resource_waiting_list" do
    get :show, id: @resource_waiting_list.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_waiting_list.to_param
    assert_response :success
  end

  test "should update resource_waiting_list" do
    put :update, id: @resource_waiting_list.to_param, resource_waiting_list: @resource_waiting_list.attributes
    assert_redirected_to resource_waiting_list_path(assigns(:resource_waiting_list))
  end

  test "should destroy resource_waiting_list" do
    assert_difference('Resource::WaitingList.count', -1) do
      delete :destroy, id: @resource_waiting_list.to_param
    end

    assert_redirected_to resource_waiting_lists_path
  end
end
