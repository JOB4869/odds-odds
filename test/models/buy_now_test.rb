require "test_helper"

class BuyNowTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product = products(:one)
    # Ensure user has some balance for process_purchase test
    # @user.update!(beer_balance: 1000)
    @buy_now = BuyNow.new(user: @user, product: @product, amount: 2)
  end

  test "should be valid with user, product, and amount" do
    assert @buy_now.valid?, "BuyNow should be valid. Errors: #{@buy_now.errors.full_messages.inspect}"
  end

  # --- Association Tests ---
  test "should belong to user" do
    assert_respond_to @buy_now, :user
  end

  test "should belong to product" do
    assert_respond_to @buy_now, :product
  end

  test "should have one attached proof_of_payment" do
    assert_respond_to @buy_now, :proof_of_payment
  end

  # --- Enum Tests ---
  test "should have status enum with default pending" do
    assert_equal "pending", @buy_now.status
    assert BuyNow.statuses.include?("pending")
    assert BuyNow.statuses.include?("completed")
  end

  test "should have address_method enum" do
    assert BuyNow.address_methods.include?("current_address")
    assert BuyNow.address_methods.include?("tipco_address")
  end

  test "should have payment_method enum" do
    assert BuyNow.payment_methods.include?("promptpay")
    assert BuyNow.payment_methods.include?("cash_on_delivery")
  end

  # --- Validation Tests ---
  test "should be invalid without user" do
    @buy_now.user = nil
    assert_not @buy_now.valid?
    assert_includes @buy_now.errors[:user], "must exist"
  end

  test "should be invalid without product" do
    @buy_now.product = nil
    assert_not @buy_now.valid?
    assert_includes @buy_now.errors[:product], "must exist"
  end

  test "should be invalid without amount" do
    @buy_now.amount = nil
    assert_not @buy_now.valid?
    assert_includes @buy_now.errors[:amount], "can't be blank"
  end

  test "should be invalid with non-positive amount" do
    @buy_now.amount = 0
    assert_not @buy_now.valid?
    assert_includes @buy_now.errors[:amount], "must be greater than 0"
    @buy_now.amount = -1
    assert_not @buy_now.valid?
    assert_includes @buy_now.errors[:amount], "must be greater than 0"
  end

  test "should be invalid without original_amount on update" do
    @buy_now.save! # Save first
    @buy_now.original_amount = nil # Manually set to nil for test
    assert_not @buy_now.valid?(:update)
    assert_includes @buy_now.errors[:original_amount], "can't be blank"
  end

  # --- Callback Tests ---
  test "before_create should set original_amount" do
    buy_now = BuyNow.new(user: @user, product: @product, amount: 5)
    assert_nil buy_now.original_amount
    buy_now.save!
    assert_equal 5, buy_now.original_amount
  end

  test "after_create should mark status as completed (Potential Issue?)" do
    # This seems counter-intuitive, usually starts pending. Testing current behavior.
    buy_now = BuyNow.create!(user: @user, product: @product, amount: 1)
    assert buy_now.completed?, "BuyNow should be completed immediately after create due to callback"
  end

  test "after_update should update beer_balance if status changes to completed AND product_id is nil" do
    # Create a pending BuyNow for beer (product_id: nil)
    beer_product = nil # Representing beer purchase
    buy_now_beer = BuyNow.create!(user: @user, product_id: beer_product, amount: 3, status: :pending)
    initial_balance = @user.reload.beer_balance

    # Update status to completed
    buy_now_beer.update!(status: :completed)

    assert_equal initial_balance + 3, @user.reload.beer_balance
  end

  test "after_update should NOT update beer_balance if status not changed to completed" do
    buy_now_beer = BuyNow.create!(user: @user, product_id: nil, amount: 3, status: :completed)
    initial_balance = @user.reload.beer_balance
    # Update something else
    buy_now_beer.update!(payment_method: :cash_on_delivery)
    assert_equal initial_balance, @user.reload.beer_balance
  end

  test "after_update should NOT update beer_balance if product_id is present" do
    buy_now_product = BuyNow.create!(user: @user, product: @product, amount: 1, status: :pending)
    initial_balance = @user.reload.beer_balance
    buy_now_product.update!(status: :completed)
    assert_equal initial_balance, @user.reload.beer_balance
  end

  # --- Method Tests ---
  test "#total_price should calculate price * amount" do
    # Assuming product is associated for this test case
    product_for_test = products(:two) # Use a different product or create one
    product_for_test.update!(price: 150)
    buy_now_with_product = BuyNow.new(user: @user, product: product_for_test, amount: 3)
    assert_equal 450, buy_now_with_product.total_price
  end

  # Commenting out tests for non-existent process_purchase method
  # test "#process_purchase should withdraw amount from user balance and return true if sufficient" do
  #   @product.update!(price: 100)
  #   buy_now_process = BuyNow.create!(user: @user, product: @product, amount: 2) # Total 200
  #   initial_balance = @user.reload.beer_balance # Should be 100 from fixture
  #   assert buy_now_process.process_purchase
  #   assert_equal initial_balance - 200, @user.reload.beer_balance # This logic might be wrong/elsewhere
  # end
  #
  # test "#process_purchase should return false if user balance insufficient" do
  #   @product.update!(price: 600)
  #   buy_now_process = BuyNow.create!(user: @user, product: @product, amount: 2) # Total 1200
  #   initial_balance = @user.reload.beer_balance # Should be 100
  #   assert_not buy_now_process.process_purchase
  #   assert_equal initial_balance, @user.reload.beer_balance # Balance should not change
  # end

  # test "the truth" do
  #   assert true
  # end
end
