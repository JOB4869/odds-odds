class Cart < ApplicationRecord
  belongs_to :user

  before_save :set_default_items

  def add_product(product_id)
    product = Product.find_by(id: product_id)

    if product.nil?
      raise "สินค้านี้ไม่มีอยู่ในระบบแล้ว"
    end

    if product.sold?
      raise "สินค้านี้ถูกขายไปแล้ว"
    end

    cart_items = self.items || []

    unless cart_items.any? { |item| item["product_id"] == product.id }
      cart_items << {
        "product_id" => product.id,
        "name" => product.name,
        "price" => product.price.to_f
      }
    end

    self.items = cart_items
    save
  end

  def remove_item(product_id)
    self.items = items.reject { |item| item["product_id"] == product_id }
    save
  end

  def clear_cart
    self.items = []
    save
  end

  def total_price
    items.sum { |item| item["price"].to_f }
  end

  private

  def set_default_items
    self.items ||= []
  end
end
