require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get edit" do
    get edit_password_url
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    sign_out @user
    get edit_password_url
    assert_redirected_to sign_in_url
  end

  test "should redirect update when not logged in" do
    sign_out @user
    patch password_url, params: { user: { password: "NewP@ssword1", password_confirmation: "NewP@ssword1" } }
    assert_redirected_to sign_in_url
  end

  test "should update password with valid parameters" do
    patch password_url, params: { user: { password: "NewP@ssword1", password_confirmation: "NewP@ssword1" } }
    assert_redirected_to users_path
    assert_equal "เปลี่ยนรหัสผ่านสำเร็จ", flash[:notice]
    assert @user.reload.authenticate("NewP@ssword1")
  end

  test "should not update password with invalid password format" do
    patch password_url, params: { user: { password: "short", password_confirmation: "short" } }
    assert_response :unprocessable_entity
    assert_template :edit
    assert_equal "รหัสผ่านไม่ถูกต้อง", flash.now[:alert]
  end

  test "should not update password if passwords do not match" do
    patch password_url, params: { user: { password: "NewP@ssword1", password_confirmation: "MismatchP@ss1" } }
    assert_response :unprocessable_entity
    assert_template :edit
    assert_equal "รหัสผ่านไม่ถูกต้อง", flash.now[:alert]
  end
end
