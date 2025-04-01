require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  # include Devise::Test::IntegrationHelpers # ลบออก

  setup do
    @user = users(:one)
    integration_sign_in @user # เปลี่ยนเป็น integration_sign_in
  end

  test "should redirect index when not logged in" do
    delete sign_out_path # ใช้ path ของ Devise เพื่อ sign out
    get accounts_url
    assert_redirected_to new_user_session_url
  end

  test "should get index when logged in" do
    get accounts_url
    assert_response :success
  end

  test "should redirect show when not logged in" do
    delete sign_out_path
    get account_url(@user)
    assert_redirected_to new_user_session_url
  end

  test "should get show when logged in" do
    get account_url(@user)
    assert_response :success
  end

  test "should redirect new when not logged in" do
    delete sign_out_path
    get new_account_url
    assert_redirected_to new_user_session_url
  end

  test "should get new when logged in" do
    get new_account_url
    assert_response :success
  end

  test "should redirect create when not logged in" do
    delete sign_out_path
    post accounts_url, params: { user: { email: "new@example.com", password: "password", password_confirmation: "password" } }
    assert_redirected_to new_user_session_url
  end

  test "should create account with valid parameters" do
    assert_difference("User.count", 1) do
      post accounts_url, params: { user: { first_name: "Test", last_name: "User", email: "create.test@example.com", password: "password", password_confirmation: "password" } }
    end
    assert_redirected_to accounts_path
    assert_equal "บันทึกข้อมูลสำเร็จ", flash[:notice]
  end

  test "should not create account with invalid parameters" do
    assert_no_difference("User.count") do
      post accounts_url, params: { user: { email: "invalid" } }
    end
    assert_response :unprocessable_entity
    assert_template :new
  end

  test "should redirect edit when not logged in" do
    delete sign_out_path
    get edit_account_url(@user)
    assert_redirected_to new_user_session_url
  end

  test "should get edit when logged in" do
    get edit_account_url(@user)
    assert_response :success
  end

  test "should redirect update when not logged in" do
    delete sign_out_path
    patch account_url(@user), params: { user: { first_name: "Updated Name" } }
    assert_redirected_to new_user_session_url
  end

  test "should update account with valid parameters" do
    patch account_url(@user), params: { user: { first_name: "Updated First Name", last_name: "Updated Last Name" } }
    assert_redirected_to accounts_path
    assert_equal "อัพเดทข้อมูลสำเร็จ", flash[:notice]
    @user.reload
    assert_equal "Updated First Name", @user.first_name
    assert_equal "Updated Last Name", @user.last_name
  end

  test "should not update account with invalid parameters" do
    patch account_url(@user), params: { user: { email: "invalid" } }
    assert_response :unprocessable_entity
    assert_template :edit
    assert_equal "กรุณาตรวจสอบข้อมูลที่กรอก", flash.now[:alert]
  end

  test "should get show" do
    get account_url(@user)
    assert_response :success
  end
end
