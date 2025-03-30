require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'should validate presence of name' do
      product = Product.new(price: 100)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("กรุณากรอกชื่อสินค้า")
    end

    it 'should validate presence of price' do
      product = Product.new(name: 'Test Product')
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("กรุณากรอกราคา")
    end

    it 'should validate price is greater than or equal to 0' do
      product = Product.new(name: 'Test Product', price: -1)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("ต้องมากกว่าหรือเท่ากับ 0")
    end
  end

  describe 'associations' do
    it 'should belong to user' do
      product = Product.reflect_on_association(:user)
      expect(product.macro).to eq :belongs_to
    end
  end
end
