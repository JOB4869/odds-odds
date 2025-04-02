require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(password: "password", password_confirmation: "password") unless @user.authenticate("password")
  end

  test "should get new (login page)" do
    get sign_in_url
    assert_response :success
  end

  test "should log in user with correct credentials" do
    post sign_in_url, params: { email: @user.email, password: "password" }
    assert_redirected_to users_path
    assert_equal "เข้าสู่ระบบสำเร็จ", flash[:notice]
    assert_equal @user.id, session[:user_id]
  end

  test "should not log in user with incorrect password" do
    post sign_in_url, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_template :new
    assert_equal "รหัสผ่านไม่ถูกต้อง", flash.now[:alert]
    assert_nil session[:user_id]
  end

  test "should not log in user with nonexistent email" do
    post sign_in_url, params: { email: "nonexistent@example.com", password: "password" }
    assert_response :unprocessable_entity
    assert_template :new
    assert_equal "ไม่พบอีเมลนี้ในระบบ", flash.now[:alert]
    assert_nil session[:user_id]
  end

  test "should get sign_out_modal page" do
    get sign_out_modal_url
    assert_response :success
  end
end
