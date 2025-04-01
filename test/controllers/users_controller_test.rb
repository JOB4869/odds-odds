require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # include Devise::Test::IntegrationHelpers # ลบออก

  setup do
    @user = users(:one)
    integration_sign_in @user # เปลี่ยนเป็น integration_sign_in

    @user.buy_nows.where(product_id: nil).destroy_all
  end

  test "should redirect index when not logged in" do
    delete sign_out_path
    get users_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect drink when not logged in" do
    delete sign_out_path
    post drink_users_url
    assert_redirected_to new_user_session_url
  end


  test "should get index" do
    get users_url
    assert_response :success
    assert_equal @user, assigns(:user)
  end

  test "should drink beer successfully if available" do
    @user.buy_nows.create!(amount: 3, status: :completed, product_id: nil)
    assert_equal 3, @user.beer_balance

    post drink_users_url

    assert_redirected_to user_dashboard_path
    assert_equal "ดื่มเบียร์แล้ว! 🍻 เหลือ 2 แก้ว", flash[:notice]
    assert_equal 2, @user.reload.beer_balance
    latest_beer_buy_now = @user.buy_nows.completed.where(product_id: nil).order(created_at: :desc).first
    assert_equal 2, latest_beer_buy_now.amount
  end

  test "should show alert if no beer available to drink" do
    assert_equal 0, @user.beer_balance

    post drink_users_url

    assert_redirected_to user_dashboard_path
    assert_equal "ไม่มีเบียร์เหลือแล้ว! ไปเติมเลย! 🍺", flash[:alert]
    assert_equal 0, @user.reload.beer_balance
  end
end
