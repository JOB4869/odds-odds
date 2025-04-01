require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_password_reset_url
    assert_response :success
  end

  test "should send password reset email if user exists" do
    assert_emails 1 do
      post password_resets_url, params: { email: @user.email }
    end
    assert_redirected_to root_path
    assert_equal "ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว", flash[:notice]
  end

  test "should show alert if user does not exist" do
    assert_no_emails do
      post password_resets_url, params: { email: "nonexistent@example.com" }
    end
    assert_response :unprocessable_entity
    assert_template :new
    assert_equal "ไม่พบอีเมลนี้ในระบบ", flash.now[:alert]
  end

  test "should get edit with valid token" do
    token = @user.generate_token_for(:password_reset)
    get edit_password_reset_url(token: token)
    assert_response :success
    assert_select "input[name='user[password]']"
  end

  test "should redirect to sign_in if token is invalid" do
    get edit_password_reset_url(token: "invalid_token")
    assert_redirected_to sign_in_path
    assert_equal "ลิงก์รีเซ็ตรหัสผ่านหมดอายุแล้ว กรุณาขอลิงก์ใหม่", flash[:alert]
  end

  test "should redirect to sign_in if token has expired" do
    token = @user.generate_token_for(:password_reset)
    travel 3.hours
    get edit_password_reset_url(token: token)
    travel_back
    assert_redirected_to sign_in_path
    assert_equal "ลิงก์รีเซ็ตรหัสผ่านหมดอายุแล้ว กรุณาขอลิงก์ใหม่", flash[:alert]
  end

  test "should update password with valid token and valid password" do
    token = @user.generate_token_for(:password_reset)
    patch password_reset_url(token: token), params: {
      user: { password: "NewP@ssword1", password_confirmation: "NewP@ssword1" }
    }
    assert_redirected_to sign_in_path
    assert_equal "รีเซ็ตรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่", flash[:notice]
    assert @user.reload.authenticate("NewP@ssword1")
  end

  test "should not update password with invalid token" do
    patch password_reset_url(token: "invalid_token"), params: {
      user: { password: "NewP@ssword1", password_confirmation: "NewP@ssword1" }
    }
    assert_redirected_to sign_in_path
    assert_equal "ลิงก์รีเซ็ตรหัสผ่านหมดอายุแล้ว กรุณาขอลิงก์ใหม่", flash[:alert]
  end

  test "should not update password with invalid password format" do
    token = @user.generate_token_for(:password_reset)
    patch password_reset_url(token: token), params: {
      user: { password: "short", password_confirmation: "short" }
    }
    assert_response :unprocessable_entity
    assert_template :edit
    assert_equal "รหัสผ่านไม่ถูกต้อง", flash.now[:alert]
  end

  test "should not update password if passwords do not match" do
    token = @user.generate_token_for(:password_reset)
    patch password_reset_url(token: token), params: {
      user: { password: "NewP@ssword1", password_confirmation: "MismatchP@ss1" }
    }
    assert_response :unprocessable_entity
    assert_template :edit
    assert_equal "รหัสผ่านไม่ถูกต้อง", flash.now[:alert]
  end
end
