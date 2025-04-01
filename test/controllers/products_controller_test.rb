require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @user_complete_profile = users(:one)
    @user_incomplete_profile = users(:two)
    @other_user = users(:three)

    @user_complete_profile.update!(first_name: "Complete", last_name: "User", address: "123 Main St", phone: "1234567890", prompt_pay: "0987654321")
    @user_incomplete_profile.update!(first_name: nil) # Ensure one field is blank

    @product_owned = @user_complete_profile.products.create!(name: "Owned Product", price: 100)
    @product_other = @other_user.products.create!(name: "Other Product", price: 200)
  end

  def sign_in_user(user)
    sign_out :user
    sign_in user
  end

  test "should redirect index when not logged in" do
    get products_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect index when profile is incomplete" do
    sign_in_user(@user_incomplete_profile)
    get products_url
    assert_redirected_to accounts_path
    assert_equal "กรุณากรอกข้อมูลบัญชีผู้ใช้ให้ครบถ้วนก่อนเข้าถึงหน้าสินค้าของฉัน", flash[:alert]
  end

  test "should allow access when logged in and profile is complete" do
    sign_in_user(@user_complete_profile)
    get products_url
    assert_response :success
  end


  test "should get index for current user" do
    sign_in_user(@user_complete_profile)
    get products_url
    assert_response :success
    assert_not_nil assigns(:products)
    assert assigns(:products).include?(@product_owned)
    assert_not assigns(:products).include?(@product_other)
  end

  test "should show own product" do
    sign_in_user(@user_complete_profile)
    get product_url(@product_owned)
    assert_response :success
    assert_equal @product_owned, assigns(:product)
  end

  test "should show other user product (if allowed - current logic allows)" do
    sign_in_user(@user_complete_profile)
    get product_url(@product_other)
    assert_response :success
    assert_equal @product_other, assigns(:product)
  end

  test "should get new" do
    sign_in_user(@user_complete_profile)
    get new_product_url
    assert_response :success
    assert_not_nil assigns(:product)
    assert assigns(:product).new_record?
  end

  test "should create product with valid data and images" do
    sign_in_user(@user_complete_profile)
    image1 = fixture_file_upload("files/product1.jpg", "image/jpeg")
    image2 = fixture_file_upload("files/product2.png", "image/png")
    assert_difference("@user_complete_profile.products.count", 1) do
      post products_url, params: { product: { name: "New Gadget", price: 199.99, description: "Latest tech", images: [ image1, image2 ] } }
    end
    assert_redirected_to products_path
    assert_equal "เพิ่มสินค้าเรียบร้อยแล้ว", flash[:notice]
    created_product = Product.last
    assert_equal "New Gadget", created_product.name
    assert_equal 2, created_product.images.count
  end

  test "should not create product with invalid data" do
    sign_in_user(@user_complete_profile)
    assert_no_difference("Product.count") do
      post products_url, params: { product: { name: "", price: -10 } }
    end
    assert_response :unprocessable_entity
    assert_template :new
  end

  test "should get edit for own product" do
    sign_in_user(@user_complete_profile)
    get edit_product_url(@product_owned)
    assert_response :success
    assert_equal @product_owned, assigns(:product)
  end

  test "should redirect from edit for other user product" do
    sign_in_user(@user_complete_profile)
    get edit_product_url(@product_other)
    assert_redirected_to products_path
    assert_equal "คุณไม่มีสิทธิ์แก้ไขสินค้านี้", flash[:alert]
  end

  test "should update own product" do
    sign_in_user(@user_complete_profile)
    patch product_url(@product_owned), params: { product: { name: "Updated Name", price: 150 } }
    assert_redirected_to products_path
    assert_equal "อัปเดตสินค้าเรียบร้อยแล้ว", flash[:notice]
    @product_owned.reload
    assert_equal "Updated Name", @product_owned.name
    assert_equal 150, @product_owned.price
  end

  test "should not update other user product" do
    sign_in_user(@user_complete_profile)
    original_name = @product_other.name
    patch product_url(@product_other), params: { product: { name: "Attempted Update" } }
    assert_redirected_to products_path
    assert_equal "คุณไม่มีสิทธิ์แก้ไขสินค้านี้", flash[:alert]
    @product_other.reload
    assert_equal original_name, @product_other.name
  end

   test "should destroy own product" do
    sign_in_user(@user_complete_profile)
    assert_difference("Product.count", -1) do
      delete product_url(@product_owned)
    end
    assert_redirected_to products_path
    assert_equal "ลบสินค้าเรียบร้อยแล้ว", flash[:notice]
    assert_equal :see_other, response.status
  end

  test "should not destroy other user product" do
    sign_in_user(@user_complete_profile)
    assert_no_difference("Product.count") do
      delete product_url(@product_other)
    end
    assert_redirected_to products_path
    assert_equal "คุณไม่มีสิทธิ์ลบสินค้านี้", flash[:alert]
  end

  test "should get customers for own product" do
    sign_in_user(@user_complete_profile)
    buyer = users(:two) # Use another user as buyer
    buy_now = @product_owned.buy_nows.create!(user: buyer, amount: 1, status: :completed)

    get customers_product_url(@product_owned)

    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:buy_nows)
    assert_equal @product_owned, assigns(:product)
    assert assigns(:buy_nows).include?(buy_now)
  end

  test "should handle customers for product with no buy_nows" do
     sign_in_user(@user_complete_profile)
     get customers_product_url(@product_owned)
     assert_response :success
     assert assigns(:buy_nows).empty?
  end
end
