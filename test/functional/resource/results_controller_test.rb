require 'test_helper'

class Resource::ResultsControllerTest < ActionController::TestCase
  setup do
    @resource_result = resource_results(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_results)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_result" do
    assert_difference('Resource::Result.count') do
      post :create, resource_result: @resource_result.attributes
    end

    assert_redirected_to resource_result_path(assigns(:resource_result))
  end

  test "should show resource_result" do
    get :show, id: @resource_result.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_result.to_param
    assert_response :success
  end

  test "should update resource_result" do
    put :update, id: @resource_result.to_param, resource_result: @resource_result.attributes
    assert_redirected_to resource_result_path(assigns(:resource_result))
  end

  test "should destroy resource_result" do
    assert_difference('Resource::Result.count', -1) do
      delete :destroy, id: @resource_result.to_param
    end

    assert_redirected_to resource_results_path
  end
end
