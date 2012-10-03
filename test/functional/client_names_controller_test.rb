require 'test_helper'

class ClientNamesControllerTest < ActionController::TestCase
  setup do
    @client_name = client_names(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:client_names)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client_name" do
    assert_difference('ClientName.count') do
      post :create, client_name: @client_name.attributes
    end

    assert_redirected_to client_name_path(assigns(:client_name))
  end

  test "should show client_name" do
    get :show, id: @client_name.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @client_name.to_param
    assert_response :success
  end

  test "should update client_name" do
    put :update, id: @client_name.to_param, client_name: @client_name.attributes
    assert_redirected_to client_name_path(assigns(:client_name))
  end

  test "should destroy client_name" do
    assert_difference('ClientName.count', -1) do
      delete :destroy, id: @client_name.to_param
    end

    assert_redirected_to client_names_path
  end
end
