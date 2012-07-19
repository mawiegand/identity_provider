require 'test_helper'

class GrantedScopesControllerTest < ActionController::TestCase
  setup do
    @granted_scope = granted_scopes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:granted_scopes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create granted_scope" do
    assert_difference('GrantedScope.count') do
      post :create, granted_scope: @granted_scope.attributes
    end

    assert_redirected_to granted_scope_path(assigns(:granted_scope))
  end

  test "should show granted_scope" do
    get :show, id: @granted_scope.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @granted_scope.to_param
    assert_response :success
  end

  test "should update granted_scope" do
    put :update, id: @granted_scope.to_param, granted_scope: @granted_scope.attributes
    assert_redirected_to granted_scope_path(assigns(:granted_scope))
  end

  test "should destroy granted_scope" do
    assert_difference('GrantedScope.count', -1) do
      delete :destroy, id: @granted_scope.to_param
    end

    assert_redirected_to granted_scopes_path
  end
end
