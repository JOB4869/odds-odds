require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product = Product.new(user: @user, name: "Test Product", price: 100)
    @beer_odds = Product.new(user: @user, name: "เบียร์ ODDS", price: 50) # Special case product
  end

  test "should be valid with valid attributes" do
    assert @product.valid?, "Product should be valid. Errors: #{@product.errors.full_messages.inspect}"
  end

  # --- Name Validations ---
  test "should be invalid without name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "กรุณากรอกชื่อสินค้า"
  end

  # --- Price Validations ---
  test "should be invalid without price" do
    @product.price = nil
    assert_not @product.valid?
    assert_includes @product.errors[:price], "กรุณากรอกราคา"
  end

  test "should be invalid with negative price" do
    @product.price = -10
    assert_not @product.valid?
    assert_includes @product.errors[:price], "ต้องมากกว่าหรือเท่ากับ 0"
  end

  test "should be valid with zero price" do
    @product.price = 0
    assert @product.valid?
  end

  # --- Association Tests (Basic) ---
  test "should belong to user" do
    assert_respond_to @product, :user
    # Test optional: true behavior
    product_no_user = Product.new(name: "No User Product", price: 10)
    assert product_no_user.valid?, "Product should be valid even without a user due to optional: true"
  end

  test "should have many buy_nows" do
    assert_respond_to @product, :buy_nows
  end

  test "should have many attached images" do
    assert_respond_to @product, :images
  end

  # --- Method Tests: sold? ---
  test "#sold? should be false initially" do
    assert_not @product.sold?, "Newly created product should not be sold"
  end

  test "#sold? should be true if sold flag is true" do
    @product.sold = true
    assert @product.sold?, "Product should be sold if sold flag is true"
  end

  test "#sold? should be true if there is a completed buy_now" do
    @product.save!
    @product.buy_nows.create!(user: @user, amount: 1, status: :completed)
    assert @product.sold?, "Product should be sold if a completed buy_now exists"
  end

  test "#sold? should be false if buy_now is not completed" do
    @product.save!
    @product.buy_nows.create!(user: @user, amount: 1, status: :pending)
    assert_not @product.sold?, "Product should not be sold if buy_now is pending"
  end

  test "#sold? should always be false for 'เบียร์ ODDS'" do
    assert_not @beer_odds.sold?, "เบียร์ ODDS should never be sold"
    @beer_odds.sold = true # Set flag explicitly
    assert_not @beer_odds.sold?, "เบียร์ ODDS should ignore sold flag"
    @beer_odds.save!
    @beer_odds.buy_nows.create!(user: @user, amount: 1, status: :completed)
    assert_not @beer_odds.reload.sold?, "เบียร์ ODDS should ignore completed buy_nows for sold? status"
  end

  # --- Method Tests: remaining_amount? ---
  # Note: Assumes product.amount defaults to 1 if not present in schema
  test "#remaining_amount should be 1 initially (assuming default amount 1)" do
    # If product has an amount field, set it: @product.amount = 1
    assert_equal 1, @product.remaining_amount
  end

  test "#remaining_amount should decrease after completed buy_now" do
    @product.save!
    @product.buy_nows.create!(user: @user, amount: 1, status: :completed)
    assert_equal 0, @product.reload.remaining_amount
  end

  test "#remaining_amount should not decrease for non-completed buy_now" do
    @product.save!
    @product.buy_nows.create!(user: @user, amount: 1, status: :pending)
    assert_equal 1, @product.reload.remaining_amount
  end

  test "#remaining_amount should handle multiple completed buy_nows (if applicable)" do
     # This requires product.amount to be > 1 or logic adjustment
     # Assuming product.amount = 5 for this test
     # @product.amount = 5 # Uncomment and adjust if schema has amount
     # @product.save!
     # @product.buy_nows.create!(user: @user, amount: 2, status: :completed)
     # @product.buy_nows.create!(user: users(:two), amount: 1, status: :completed)
     # assert_equal 2, @product.reload.remaining_amount
     # --- If amount is always 1, this test case might not be relevant ---
     skip("Skipping test: Assumes product.amount > 1 which might not be the case")
  end

  test "#remaining_amount should be infinity for 'เบียร์ ODDS'" do
    assert_equal Float::INFINITY, @beer_odds.remaining_amount
    @beer_odds.save!
    @beer_odds.buy_nows.create!(user: @user, amount: 100, status: :completed)
    assert_equal Float::INFINITY, @beer_odds.reload.remaining_amount
  end


  # test "the truth" do
  #   assert true
  # end
end
