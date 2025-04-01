require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @user = users(:one)
    @product1 = products(:one)
    @product2 = products(:two)

    [ @product1, @product2 ].each { |p| p.update!(sold: false) if p.persisted? }

    @cart = Cart.find_or_create_by!(user: @user)
    @cart.clear_cart

    sign_in @user
  end

  test "should redirect show when not logged in" do
    sign_out @user
    get current_carts_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect add when not logged in" do
    sign_out @user
    post add_product_carts_url(product_id: @product1.id)
    assert_redirected_to new_user_session_url
  end

  test "should redirect remove_item when not logged in" do
    sign_out @user
    delete remove_item_carts_url(product_id: @product1.id)
    assert_redirected_to new_user_session_url
  end

  test "should redirect clear when not logged in" do
    sign_out @user
    delete clear_carts_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect purchase_all when not logged in" do
    sign_out @user
    get purchase_all_carts_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect confirm_purchase_all when not logged in" do
    sign_out @user
    post confirm_purchase_all_carts_url, params: { cart_items: [ @product1.id ] }
    assert_redirected_to new_user_session_url
  end


  test "should show cart (current)" do
    @cart.add_product(@product1.id)
    get current_carts_url
    assert_response :success
    assert_not_nil assigns(:cart)
    assert_select "td", text: @product1.name
  end

  test "should add product to cart" do
    assert_difference "@cart.items.count", 1 do
      post add_product_carts_url(product_id: @product1.id)
      @cart.reload
    end
    assert_redirected_to root_path
    assert_equal "เพิ่มสินค้าลงตะกร้าเรียบร้อยแล้ว", flash[:notice]
    assert @cart.items.any? { |item| item["product_id"] == @product1.id }
  end

  test "should increment quantity if product already in cart" do
    post add_product_carts_url(product_id: @product1.id)
    @cart.reload
    initial_quantity = @cart.items.find { |item| item["product_id"] == @product1.id }["quantity"]

    assert_no_difference "@cart.items.count" do
       post add_product_carts_url(product_id: @product1.id)
       @cart.reload
    end

    assert_redirected_to root_path
    assert_equal "เพิ่มสินค้าลงตะกร้าเรียบร้อยแล้ว", flash[:notice]
    final_quantity = @cart.items.find { |item| item["product_id"] == @product1.id }["quantity"]
    assert_equal initial_quantity + 1, final_quantity
  end

  test "should remove item from cart" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    @cart.reload
    assert @cart.items.any? { |item| item["product_id"] == @product1.id }

    assert_difference "@cart.items.count", -1 do
      delete remove_item_carts_url(product_id: @product1.id)
      @cart.reload
    end

    assert_redirected_to current_carts_path
    assert_equal "ลบสินค้าออกจากตะกร้าเรียบร้อยแล้ว", flash[:notice]
    assert_not @cart.items.any? { |item| item["product_id"] == @product1.id }
    assert @cart.items.any? { |item| item["product_id"] == @product2.id }
  end

  test "should clear cart" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    @cart.reload
    assert @cart.items.count > 0

    delete clear_carts_url
    @cart.reload

    assert_redirected_to current_carts_path
    assert_equal "ล้างตะกร้าเรียบร้อยแล้ว", flash[:notice]
    assert @cart.items.empty?
  end


  test "should get purchase_all with available items" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    get purchase_all_carts_url
    assert_response :success
    assert_not_nil assigns(:cart_items)
    assert_not_nil assigns(:total_price)
    assert_not_nil assigns(:user)
    assert_equal 2, assigns(:cart_items).count
    assert_equal @product1.price + @product2.price, assigns(:total_price)
  end

  test "should get purchase_all and filter out sold items" do
    @product1.update!(sold: true)
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    get purchase_all_carts_url
    assert_response :success
    assert_equal 1, assigns(:cart_items).count
    assert assigns(:cart_items).any? { |item| item["product_id"] == @product2.id }
    assert_equal @product2.price, assigns(:total_price)
  end

  test "should redirect from purchase_all if cart has no available items" do
    @product1.update!(sold: true)
    @product2.update!(sold: true)
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    get purchase_all_carts_url
    assert_redirected_to current_carts_path
    assert_equal "ไม่มีสินค้าที่สามารถซื้อได้ในตะกร้า", flash[:alert]
  end

  test "should confirm purchase all with valid params (cash)" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    @cart.reload

    assert_difference "BuyNow.count", 2 do
      assert_difference "@cart.reload.items.count", -2 do
        post confirm_purchase_all_carts_url, params: {
          cart_items: [ @product1.id.to_s, @product2.id.to_s ],
          buy_now: { address_method: "pickup", payment_method: "cash" }
        }
      end
    end

    assert_redirected_to root_path
    assert_equal "สั่งซื้อสินค้าเรียบร้อยแล้ว", flash[:notice]
    assert @cart.items.empty?
    assert @product1.reload.sold?
    assert @product2.reload.sold?

    buy_now1 = BuyNow.find_by(user: @user, product: @product1)
    buy_now2 = BuyNow.find_by(user: @user, product: @product2)
    assert_not_nil buy_now1
    assert_not_nil buy_now2
    assert_equal "pickup", buy_now1.address_method
    assert_equal "cash", buy_now1.payment_method
    assert_not buy_now1.proof_of_payment.attached?
  end

  test "should confirm purchase all with valid params (promptpay with proof)" do
    @cart.add_product(@product1.id)
    proof_file = fixture_file_upload("files/slip.png", "image/png")

    assert_difference "BuyNow.count", 1 do
      assert_difference "@cart.reload.items.count", -1 do
        post confirm_purchase_all_carts_url, params: {
          cart_items: [ @product1.id.to_s ],
          buy_now: {
            address_method: "delivery",
            payment_method: "promptpay",
            proof_of_payment: proof_file
          }
        }
      end
    end

    assert_redirected_to root_path
    assert_equal "สั่งซื้อสินค้าเรียบร้อยแล้ว", flash[:notice]
    assert @product1.reload.sold?
    buy_now1 = BuyNow.find_by(user: @user, product: @product1)
    assert_not_nil buy_now1
    assert buy_now1.proof_of_payment.attached?
  end

  test "should not confirm purchase all if address_method is missing" do
     @cart.add_product(@product1.id)
    assert_no_difference [ "BuyNow.count", "@cart.reload.items.count" ] do
      post confirm_purchase_all_carts_url, params: {
        cart_items: [ @product1.id.to_s ],
        buy_now: { payment_method: "cash" }
      }
    end
    assert_redirected_to purchase_all_carts_path
    assert_equal "กรุณาเลือกที่รับสินค้า", flash[:alert]
    assert_not @product1.reload.sold?
  end

  test "should not confirm purchase all if payment_method is promptpay and proof is missing" do
    @cart.add_product(@product1.id)
    assert_no_difference [ "BuyNow.count", "@cart.reload.items.count" ] do
      post confirm_purchase_all_carts_url, params: {
        cart_items: [ @product1.id.to_s ],
        buy_now: { address_method: "pickup", payment_method: "promptpay" }
      }
    end
    assert_redirected_to purchase_all_carts_path
    assert_equal "กรุณาอัพโหลดหลักฐานการชำระเงิน", flash[:alert]
    assert_not @product1.reload.sold?
  end

  test "should not confirm purchase all if one item becomes sold during process" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)

    @product1.update!(sold: true)

    assert_no_difference [ "BuyNow.count", "@cart.reload.items.count" ] do
      post confirm_purchase_all_carts_url, params: {
        cart_items: [ @product1.id.to_s, @product2.id.to_s ],
        buy_now: { address_method: "pickup", payment_method: "cash" }
      }
    end

    assert_redirected_to current_carts_path
    assert_equal "มีสินค้าบางรายการถูกขายไปแล้ว กรุณาตรวจสอบและลองใหม่อีกครั้ง", flash[:alert]
    assert @product1.reload.sold? # Still sold
    assert_not @product2.reload.sold? # Product 2 should not be marked sold
  end

  test "should show cart" do
    get cart_url
    assert_response :success
  end
end
