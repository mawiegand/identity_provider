require 'test_helper'

class Shop::FbPaymentsLogsControllerTest < ActionController::TestCase
  setup do
    @shop_fb_payments_log = shop_fb_payments_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shop_fb_payments_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shop_fb_payments_log" do
    assert_difference('Shop::FbPaymentsLog.count') do
      post :create, shop_fb_payments_log: @shop_fb_payments_log.attributes
    end

    assert_redirected_to shop_fb_payments_log_path(assigns(:shop_fb_payments_log))
  end

  test "should show shop_fb_payments_log" do
    get :show, id: @shop_fb_payments_log.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shop_fb_payments_log.to_param
    assert_response :success
  end

  test "should update shop_fb_payments_log" do
    put :update, id: @shop_fb_payments_log.to_param, shop_fb_payments_log: @shop_fb_payments_log.attributes
    assert_redirected_to shop_fb_payments_log_path(assigns(:shop_fb_payments_log))
  end

  test "should destroy shop_fb_payments_log" do
    assert_difference('Shop::FbPaymentsLog.count', -1) do
      delete :destroy, id: @shop_fb_payments_log.to_param
    end

    assert_redirected_to shop_fb_payments_logs_path
  end
end
