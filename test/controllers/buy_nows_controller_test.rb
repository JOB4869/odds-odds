require "test_helper"

class BuyNowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @buy_now = buy_nows(:one)
  end

  test "should get index" do
    get buy_nows_url
    assert_response :success
  end

  test "should get new" do
    get new_buy_now_url
    assert_response :success
  end

  test "should create buy_now" do
    assert_difference("BuyNow.count") do
      post buy_nows_url, params: { buy_now: { amount: @buy_now.amount, proof_of_payment: @buy_now.proof_of_payment, status: @buy_now.status, user_id: @buy_now.user_id } }
    end

    assert_redirected_to buy_now_url(BuyNow.last)
  end

  test "should show buy_now" do
    get buy_now_url(@buy_now)
    assert_response :success
  end

  test "should get edit" do
    get edit_buy_now_url(@buy_now)
    assert_response :success
  end

  test "should update buy_now" do
    patch buy_now_url(@buy_now), params: { buy_now: { amount: @buy_now.amount, proof_of_payment: @buy_now.proof_of_payment, status: @buy_now.status, user_id: @buy_now.user_id } }
    assert_redirected_to buy_now_url(@buy_now)
  end

  test "should destroy buy_now" do
    assert_difference("BuyNow.count", -1) do
      delete buy_now_url(@buy_now)
    end

    assert_redirected_to buy_nows_url
  end
end
