require 'test_helper'

class Resource::CharacterPropertiesControllerTest < ActionController::TestCase
  setup do
    @resource_character_property = resource_character_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_character_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_character_property" do
    assert_difference('Resource::CharacterProperty.count') do
      post :create, resource_character_property: @resource_character_property.attributes
    end

    assert_redirected_to resource_character_property_path(assigns(:resource_character_property))
  end

  test "should show resource_character_property" do
    get :show, id: @resource_character_property.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_character_property.to_param
    assert_response :success
  end

  test "should update resource_character_property" do
    put :update, id: @resource_character_property.to_param, resource_character_property: @resource_character_property.attributes
    assert_redirected_to resource_character_property_path(assigns(:resource_character_property))
  end

  test "should destroy resource_character_property" do
    assert_difference('Resource::CharacterProperty.count', -1) do
      delete :destroy, id: @resource_character_property.to_param
    end

    assert_redirected_to resource_character_properties_path
  end
end
