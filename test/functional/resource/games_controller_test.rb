require 'test_helper'

class Resource::GamesControllerTest < ActionController::TestCase
  setup do
    @resource_game = resource_games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_games)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_game" do
    assert_difference('Resource::Game.count') do
      post :create, resource_game: @resource_game.attributes
    end

    assert_redirected_to resource_game_path(assigns(:resource_game))
  end

  test "should show resource_game" do
    get :show, id: @resource_game.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource_game.to_param
    assert_response :success
  end

  test "should update resource_game" do
    put :update, id: @resource_game.to_param, resource_game: @resource_game.attributes
    assert_redirected_to resource_game_path(assigns(:resource_game))
  end

  test "should destroy resource_game" do
    assert_difference('Resource::Game.count', -1) do
      delete :destroy, id: @resource_game.to_param
    end

    assert_redirected_to resource_games_path
  end
end
