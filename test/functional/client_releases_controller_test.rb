require 'test_helper'

class ClientReleasesControllerTest < ActionController::TestCase
  setup do
    @client_release = client_releases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:client_releases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client_release" do
    assert_difference('ClientRelease.count') do
      post :create, client_release: @client_release.attributes
    end

    assert_redirected_to client_release_path(assigns(:client_release))
  end

  test "should show client_release" do
    get :show, id: @client_release.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @client_release.to_param
    assert_response :success
  end

  test "should update client_release" do
    put :update, id: @client_release.to_param, client_release: @client_release.attributes
    assert_redirected_to client_release_path(assigns(:client_release))
  end

  test "should destroy client_release" do
    assert_difference('ClientRelease.count', -1) do
      delete :destroy, id: @client_release.to_param
    end

    assert_redirected_to client_releases_path
  end
end
