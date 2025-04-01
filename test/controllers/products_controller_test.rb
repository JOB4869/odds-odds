require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { name: "Sample Product", price: 10.0 } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    product = products(:one)
    get product_url(product)
    assert_response :success
  end

  test "should update product" do
    product = products(:one)
    patch product_url(product), params: { product: { name: "Updated Product" } }
    assert_redirected_to product_url(product)
  end

  test "should destroy product" do
    product = products(:one)
    assert_difference("Product.count", -1) do
      delete product_url(product)
    end

    assert_redirected_to products_url
  end
end
