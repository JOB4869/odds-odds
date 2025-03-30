require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: 1)
      expect(cart_item).to be_valid
    end

    it 'should validate presence of quantity' do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: nil)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end

    it 'should validate quantity is greater than 0' do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: 0)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end
  end

  describe 'associations' do
    it 'should belong to cart' do
      cart_item = CartItem.reflect_on_association(:cart)
      expect(cart_item.macro).to eq :belongs_to
    end

    it 'should belong to product' do
      cart_item = CartItem.reflect_on_association(:product)
      expect(cart_item.macro).to eq :belongs_to
    end
  end

  describe 'factory' do
    it 'should have a valid factory' do
      cart_item = build(:cart_item)
      expect(cart_item).to be_valid
    end
  end
end
