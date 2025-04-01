require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  def setup
    @cart = carts(:one)
    @product = products(:one)
    @cart_item = CartItem.new(cart: @cart, product: @product, quantity: 1)
  end

  test "should be valid" do
    assert @cart_item.valid?
  end

  test "should require cart" do
    @cart_item.cart = nil
    assert_not @cart_item.valid?
  end

  test "should require product" do
    @cart_item.product = nil
    assert_not @cart_item.valid?
  end

  test "should require quantity" do
    @cart_item.quantity = nil
    assert_not @cart_item.valid?
  end

  test "quantity should be greater than 0" do
    @cart_item.quantity = 0
    assert_not @cart_item.valid?
    @cart_item.quantity = -1
    assert_not @cart_item.valid?
  end

  test "belongs_to cart association" do
    assert_respond_to @cart_item, :cart
  end

  test "belongs_to product association" do
    assert_respond_to @cart_item, :product
  end
end
