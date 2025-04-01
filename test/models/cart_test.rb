require "test_helper"

class CartTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product1 = products(:one)
    @product2 = products(:two)
    [ @product1, @product2 ].each { |p| p.update!(sold: false) if p.persisted? }

    @cart = Cart.find_or_create_by!(user: @user)
    @cart.clear_cart # Ensure cart is empty before each test
  end

  test "should be valid with a user" do
    assert @cart.valid?, "Cart should be valid with a user. Errors: #{@cart.errors.full_messages.inspect}"
  end

  test "should be invalid without a user" do
    cart_no_user = Cart.new
    assert_not cart_no_user.valid?
    assert_includes cart_no_user.errors[:user], "must exist"
    assert_includes cart_no_user.errors[:user], "can't be blank"
  end

  test "should initialize items as empty array on save if nil" do
    cart = Cart.new(user: @user)
    assert_nil cart.items
    cart.save!
    assert_equal [], cart.items
  end

  # --- Association Tests ---
  test "should belong to user" do
    assert_respond_to @cart, :user
    assert_equal @user, @cart.user
  end

  test "should have many cart_items" do
    assert_respond_to @cart, :cart_items
  end

  # --- Method Tests (Working with `items` array) ---

  test "#add_product should add a valid, unsold product to items array" do
    assert_difference "@cart.items.count", 1 do
      assert @cart.add_product(@product1.id)
      @cart.reload
    end
    added_item = @cart.items.find { |item| item["product_id"] == @product1.id }
    assert_not_nil added_item
    assert_equal @product1.name, added_item["name"]
    assert_equal @product1.price.to_f, added_item["price"]
  end

  test "#add_product should not add the same product twice to items array" do
     assert @cart.add_product(@product1.id) # First add
     @cart.reload
     assert_no_difference "@cart.items.count" do # Second add
       assert @cart.add_product(@product1.id)
       @cart.reload
     end
     assert_equal 1, @cart.items.count
  end

  test "#add_product should raise error if product not found" do
    assert_raises RuntimeError, "สินค้านี้ไม่มีอยู่ในระบบแล้ว" do
      @cart.add_product(99999) # Non-existent ID
    end
    assert @cart.items.empty?, "Cart items should remain empty after failed add"
  end

  test "#add_product should raise error if product is sold" do
    @product1.update!(sold: true)
    assert_raises RuntimeError, "สินค้านี้ถูกขายไปแล้ว" do
      @cart.add_product(@product1.id)
    end
    assert @cart.items.empty?, "Cart items should remain empty after failed add"
  end

  test "#remove_item should remove product from items array" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    @cart.reload
    assert_equal 2, @cart.items.count

    @cart.remove_item(@product1.id)
    @cart.reload

    assert_equal 1, @cart.items.count
    assert_not @cart.items.any? { |item| item["product_id"] == @product1.id }
    assert @cart.items.any? { |item| item["product_id"] == @product2.id }
  end

  test "#remove_item should do nothing if product not in items array" do
    @cart.add_product(@product2.id)
    @cart.reload
    assert_equal 1, @cart.items.count

    @cart.remove_item(@product1.id) # Try removing product1 which is not added
    @cart.reload

    assert_equal 1, @cart.items.count # Count should remain the same
    assert @cart.items.any? { |item| item["product_id"] == @product2.id }
  end

  test "#clear_cart should remove all items from items array" do
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    @cart.reload
    assert_equal 2, @cart.items.count

    @cart.clear_cart
    @cart.reload

    assert @cart.items.empty?
  end

  test "#total_price should calculate sum from items array" do
    assert_equal 0, @cart.total_price
    @cart.add_product(@product1.id)
    @cart.add_product(@product2.id)
    @cart.reload
    expected_total = @product1.price.to_f + @product2.price.to_f
    assert_equal expected_total, @cart.total_price
  end

  # --- Tests for methods working with `cart_items` association (Need CartItem setup) ---
  # test "#total should calculate sum from cart_items association" do
  #   # Requires CartItem records to be created and associated
  #   skip "Skipping test: Requires setup for CartItem association"
  # end

  # test "#add_item should add/update CartItem record" do
  #   skip "Skipping test: Requires setup for CartItem association"
  # end

  # test "the truth" do
  #   assert true
  # end
end
