require "test_helper"

class BuyNowsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @user = users(:one)
    @product = products(:one)
    @buy_now = BuyNow.create!(user: @user, product: @product, amount: 1, status: :pending)
    integration_sign_in @user
  end

  test "should redirect index when not logged in" do
    delete sign_out_path
    get buy_nows_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect new when not logged in" do
    delete sign_out_path
    get new_buy_now_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect create when not logged in" do
    delete sign_out_path
    assert_no_difference("BuyNow.count") do
      post buy_nows_url, params: { buy_now: { product_id: @product.id, amount: 1, address_method: "current_address", payment_method: "promptpay" } }
    end
    assert_redirected_to new_user_session_url
  end

  test "should get index" do
    get buy_nows_url
    assert_response :success
    assert_not_nil assigns(:buy_nows)
  end

  test "should get new" do
    get new_buy_now_url, params: { amount: 100 }
    assert_response :success
    assert_not_nil assigns(:buy_now)
    assert_equal 100, assigns(:buy_now).amount
  end

  test "should create buy_now with proof of payment" do
    proof_file = fixture_file_upload("files/slip.png", "image/png")
    assert_difference("@user.buy_nows.count", 1) do
      post buy_nows_url, params: {
        buy_now: {
          amount: 500,
          proof_of_payment: proof_file
        }
      }
    end

    created_buy_now = BuyNow.last
    assert_redirected_to beers_path
    assert_equal "อัปโหลดสลิปเรียบร้อย", flash[:notice]
    assert created_buy_now.proof_of_payment.attached?
    assert_equal "completed", created_buy_now.status
  end

  test "should create buy_now without proof of payment (if allowed)" do
    assert_difference("@user.buy_nows.count", 1) do
      post buy_nows_url, params: {
        buy_now: {
          amount: 300
        }
      }
    end
    assert_redirected_to beers_path
    assert_equal "อัปโหลดสลิปเรียบร้อย", flash[:notice]
    assert_not BuyNow.last.proof_of_payment.attached?
  end

  test "should not create buy_now with invalid params" do
    assert_no_difference("@user.buy_nows.count") do
      post buy_nows_url, params: { buy_now: { amount: -100 } }
    end
    assert_response :unprocessable_entity
    assert_template :new
    assert_not_nil flash.now[:alert]
  end

  test "should redirect purchase when not logged in" do
    delete sign_out_path
    get purchase_buy_now_url(@product)
    assert_redirected_to new_user_session_url
  end

  test "should get purchase" do
    get purchase_buy_now_url(@product)
    assert_response :success
    assert_not_nil assigns(:buy_now)
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:product)
    assert_equal 1, assigns(:buy_now).amount
  end

  test "should redirect confirm_purchase when not logged in" do
    delete sign_out_path
    post confirm_purchase_buy_now_url(@product), params: { buy_now: { address_method: "current_address", payment_method: "promptpay", amount: 1 } }
    assert_redirected_to new_user_session_url
  end

  test "should confirm purchase with valid params (cash)" do
    assert_difference("@user.buy_nows.count", 1) do
      post confirm_purchase_buy_now_url(@product), params: {
        buy_now: {
          payment_method: "cash",
          address_method: "pickup"
        }
      }
    end
    assert_redirected_to root_path
    assert_equal "สั่งซื้อสินค้าสำเร็จ! 🎉", flash[:notice]
    created_buy_now = BuyNow.last
    assert_equal @product.id, created_buy_now.product_id
    assert_equal "completed", created_buy_now.status
    assert_equal "cash", created_buy_now.payment_method
    assert_equal "pickup", created_buy_now.address_method
    assert_not created_buy_now.proof_of_payment.attached?
  end

  test "should confirm purchase with valid params (promptpay with proof)" do
    proof_file = fixture_file_upload("files/slip.png", "image/png")
    assert_difference("@user.buy_nows.count", 1) do
      post confirm_purchase_buy_now_url(@product), params: {
        buy_now: {
          payment_method: "promptpay",
          address_method: "delivery",
          proof_of_payment: proof_file
        }
      }
    end
    assert_redirected_to root_path
    assert_equal "สั่งซื้อสินค้าสำเร็จ! 🎉", flash[:notice]
    created_buy_now = BuyNow.last
    assert_equal @product.id, created_buy_now.product_id
    assert_equal "completed", created_buy_now.status
    assert_equal "promptpay", created_buy_now.payment_method
    assert_equal "delivery", created_buy_now.address_method
    assert created_buy_now.proof_of_payment.attached?
  end

  test "should not confirm purchase if address_method is missing" do
    assert_no_difference("@user.buy_nows.count") do
      post confirm_purchase_buy_now_url(@product), params: {
        buy_now: { payment_method: "cash" }
      }
    end
    assert_response :unprocessable_entity
    assert_template :purchase
    assert_equal "กรุณาเลือกที่รับสินค้า", flash.now[:alert]
  end

  test "should not confirm purchase if payment_method is promptpay and proof is missing" do
    assert_no_difference("@user.buy_nows.count") do
      post confirm_purchase_buy_now_url(@product), params: {
        buy_now: { payment_method: "promptpay", address_method: "pickup" }
      }
    end
    assert_response :unprocessable_entity
    assert_template :purchase
    assert_equal "กรุณาอัปโหลดหลักฐานการชำระเงิน", flash.now[:alert]
  end

  test "should redirect show when not logged in" do
    delete sign_out_path
    get buy_now_url(@buy_now)
    assert_redirected_to new_user_session_url
  end

  test "should get show" do
    @buy_now.update(product: @product)
    get buy_now_url(@buy_now)
    assert_response :success
    assert_not_nil assigns(:buy_now)
    assert_not_nil assigns(:product)
  end

  test "should redirect qr_code when not logged in" do
    delete sign_out_path
    get qr_code_buy_now_url(@buy_now)
    assert_redirected_to new_user_session_url
  end

  test "should get qr_code" do
    get qr_code_buy_now_url(@buy_now)
    assert_response :success
    assert_not_nil assigns(:buy_now)
  end

  test "should redirect confirm_payment when not logged in" do
    delete sign_out_path
    patch confirm_payment_buy_now_url(@buy_now)
    assert_redirected_to new_user_session_url
  end

  test "should confirm payment and attach proof" do
    @buy_now.update(status: "pending")
    proof_file = fixture_file_upload("files/slip.png", "image/png")

    patch confirm_payment_buy_now_url(@buy_now), params: { proof_of_payment: proof_file }

    assert_redirected_to user_dashboard_path
    assert_equal "เติมเบียร์สำเร็จ! 🍺", flash[:notice]
    @buy_now.reload
    assert @buy_now.proof_of_payment.attached?
    assert_equal "completed", @buy_now.status
  end

  test "should redirect back to qr_code if proof is missing in confirm_payment" do
    patch confirm_payment_buy_now_url(@buy_now), params: { proof_of_payment: nil }

    assert_redirected_to qr_code_buy_now_url(@buy_now)
    assert_equal "กรุณาอัปโหลดสลิปการชำระเงิน", flash[:alert]
    @buy_now.reload
    assert_not @buy_now.proof_of_payment.attached?
  end

  test "should show buy_now" do
    get buy_now_url(@buy_now)
    assert_response :success
  end

  test "should update buy_now" do
    patch buy_now_url(@buy_now), params: { buy_now: { amount: @buy_now.amount, proof_of_payment: @buy_now.proof_of_payment, status: @buy_now.status, user_id: @buy_now.user_id } }
    assert_redirected_to buy_now_url(@buy_now)
  end
end
