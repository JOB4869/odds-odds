require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new (signup page)" do
    get sign_up_url
    assert_response :success
    assert_not_nil assigns(:user)
    assert assigns(:user).new_record?
  end

  test "should create user with valid parameters" do
    assert_difference("User.count", 1) do
      post sign_up_url, params: {
        user: { email: "new.user@example.com", password: "password", password_confirmation: "password" }
      }
    end

    created_user = User.last
    assert_redirected_to additional_info_path
    assert_equal created_user.id, session[:user_id]
  end

  test "should not create user with invalid parameters" do
    assert_no_difference("User.count") do
      post sign_up_url, params: {
        user: { email: "invalid", password: "short", password_confirmation: "short" }
      }
    end
    assert_response :unprocessable_entity
    assert_template :new
    assert_nil session[:user_id]
  end

  test "should not create user if password confirmation does not match" do
    assert_no_difference("User.count") do
      post sign_up_url, params: {
        user: { email: "mismatch@example.com", password: "password", password_confirmation: "nomatch" }
      }
    end
    assert_response :unprocessable_entity
    assert_template :new
    assert_nil session[:user_id]
  end

  test "should get additional_info page" do
    post sign_up_url, params: { user: { email: "temp@example.com", password: "password", password_confirmation: "password" } }
    follow_redirect!
    assert_response :success
  end
end
