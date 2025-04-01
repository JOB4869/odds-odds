require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product1 = Product.create!(name: "Product A", price: 10)
    @product2 = Product.create!(name: "Product B", price: 20)
  end

  test "should get index when logged out" do
    get root_url
    assert_response :success
    assert_nil assigns(:user)
    assert_not_nil assigns(:products)
    assert_equal [ @product2, @product1 ], assigns(:products)
    assert_nil assigns(:current_cart)
  end

  test "should get index when logged in" do
    sign_in @user
    get root_url
    assert_response :success
    assert_equal @user, assigns(:user)
    assert_not_nil assigns(:products)
    assert_equal [ @product2, @product1 ], assigns(:products)
    assert_not_nil assigns(:current_cart)
    assert_equal @user, assigns(:current_cart).user
  end
end
