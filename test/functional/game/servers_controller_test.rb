require 'test_helper'

class Game::ServersControllerTest < ActionController::TestCase
  setup do
    @game_server = game_servers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_servers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_server" do
    assert_difference('Game::Server.count') do
      post :create, game_server: @game_server.attributes
    end

    assert_redirected_to game_server_path(assigns(:game_server))
  end

  test "should show game_server" do
    get :show, id: @game_server.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_server.to_param
    assert_response :success
  end

  test "should update game_server" do
    put :update, id: @game_server.to_param, game_server: @game_server.attributes
    assert_redirected_to game_server_path(assigns(:game_server))
  end

  test "should destroy game_server" do
    assert_difference('Game::Server.count', -1) do
      delete :destroy, id: @game_server.to_param
    end

    assert_redirected_to game_servers_path
  end
end
