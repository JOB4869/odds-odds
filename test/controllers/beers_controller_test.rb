require "test_helper"

class BeersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:one)
    Product.find_or_create_by(id: @product.id)

    @buy_now_beer = @user.buy_nows.create!(amount: 5, status: :completed, product_id: nil)
    @buy_now_product = @user.buy_nows.create!(amount: 1, status: :completed, product_id: @product.id)

    integration_sign_in @user
  end

  test "should get index" do
    get beers_url
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:buy_nows)
    assert_not_nil assigns(:total_beers)
    assert_equal 5, assigns(:total_beers)
    assert_equal 2, assigns(:buy_nows).count
  end

  test "should check out beer if available" do
    assert_difference "@buy_now_beer.reload.amount", -1 do
      post check_out_beers_url
    end
    assert_redirected_to beers_path
    assert_equal "ดื่มเบียร์สำเร็จ! ", flash[:notice]
  end

  test "should show alert if no beer available to check out" do
    @buy_now_beer.update!(amount: 0)

    assert_no_difference "BuyNow.sum(:amount)" do
      post check_out_beers_url
    end
    assert_redirected_to beers_path
    assert_equal "คุณไม่มีเบียร์ในคลัง", flash[:alert]
  end

  test "should handle case where user has no completed beer buy_nows" do
    @buy_now_beer.destroy
    assert @user.buy_nows.completed.where(product_id: nil).sum(:amount) == 0

    post check_out_beers_url
    assert_redirected_to beers_path
    assert_equal "คุณไม่มีเบียร์ในคลัง", flash[:alert]
  end
end
