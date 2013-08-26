require 'test_helper'

class Stats::MoneyTransactionsControllerTest < ActionController::TestCase
  setup do
    @stats_money_transaction = stats_money_transactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stats_money_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stats_money_transaction" do
    assert_difference('Stats::MoneyTransaction.count') do
      post :create, stats_money_transaction: @stats_money_transaction.attributes
    end

    assert_redirected_to stats_money_transaction_path(assigns(:stats_money_transaction))
  end

  test "should show stats_money_transaction" do
    get :show, id: @stats_money_transaction.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stats_money_transaction.to_param
    assert_response :success
  end

  test "should update stats_money_transaction" do
    put :update, id: @stats_money_transaction.to_param, stats_money_transaction: @stats_money_transaction.attributes
    assert_redirected_to stats_money_transaction_path(assigns(:stats_money_transaction))
  end

  test "should destroy stats_money_transaction" do
    assert_difference('Stats::MoneyTransaction.count', -1) do
      delete :destroy, id: @stats_money_transaction.to_param
    end

    assert_redirected_to stats_money_transactions_path
  end
end
