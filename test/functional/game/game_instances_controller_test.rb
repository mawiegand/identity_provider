require 'test_helper'

class Game::GameInstancesControllerTest < ActionController::TestCase
  setup do
    @game_game_instance = game_game_instances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_game_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_game_instance" do
    assert_difference('Game::GameInstance.count') do
      post :create, game_game_instance: @game_game_instance.attributes
    end

    assert_redirected_to game_game_instance_path(assigns(:game_game_instance))
  end

  test "should show game_game_instance" do
    get :show, id: @game_game_instance.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_game_instance.to_param
    assert_response :success
  end

  test "should update game_game_instance" do
    put :update, id: @game_game_instance.to_param, game_game_instance: @game_game_instance.attributes
    assert_redirected_to game_game_instance_path(assigns(:game_game_instance))
  end

  test "should destroy game_game_instance" do
    assert_difference('Game::GameInstance.count', -1) do
      delete :destroy, id: @game_game_instance.to_param
    end

    assert_redirected_to game_game_instances_path
  end
end
