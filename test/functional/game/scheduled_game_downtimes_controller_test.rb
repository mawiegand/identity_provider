require 'test_helper'

class Game::ScheduledGameDowntimesControllerTest < ActionController::TestCase
  setup do
    @game_scheduled_game_downtime = game_scheduled_game_downtimes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_scheduled_game_downtimes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_scheduled_game_downtime" do
    assert_difference('Game::ScheduledGameDowntime.count') do
      post :create, game_scheduled_game_downtime: @game_scheduled_game_downtime.attributes
    end

    assert_redirected_to game_scheduled_game_downtime_path(assigns(:game_scheduled_game_downtime))
  end

  test "should show game_scheduled_game_downtime" do
    get :show, id: @game_scheduled_game_downtime.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_scheduled_game_downtime.to_param
    assert_response :success
  end

  test "should update game_scheduled_game_downtime" do
    put :update, id: @game_scheduled_game_downtime.to_param, game_scheduled_game_downtime: @game_scheduled_game_downtime.attributes
    assert_redirected_to game_scheduled_game_downtime_path(assigns(:game_scheduled_game_downtime))
  end

  test "should destroy game_scheduled_game_downtime" do
    assert_difference('Game::ScheduledGameDowntime.count', -1) do
      delete :destroy, id: @game_scheduled_game_downtime.to_param
    end

    assert_redirected_to game_scheduled_game_downtimes_path
  end
end
