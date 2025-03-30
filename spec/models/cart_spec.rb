require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user) }

  describe 'validations' do
    it 'should validate presence of user' do
      cart = Cart.new
      expect(cart).not_to be_valid
      expect(cart.errors[:user]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'should belong to user' do
      cart = Cart.reflect_on_association(:user)
      expect(cart.macro).to eq :belongs_to
    end

    it 'should have many cart items' do
      cart = Cart.reflect_on_association(:cart_items)
      expect(cart.macro).to eq :has_many
    end
  end

  describe '#total' do
    let(:product1) { create(:product, price: 100) }
    let(:product2) { create(:product, price: 200) }

    it 'should calculate total price correctly' do
      create(:cart_item, cart: cart, product: product1, quantity: 2)
      create(:cart_item, cart: cart, product: product2, quantity: 1)

      expected_total = (product1.price * 2) + product2.price
      expect(cart.total).to eq expected_total
    end
  end

  describe '#add_item' do
    let(:product) { create(:product) }

    context 'when product is not in cart' do
      it 'should create new cart item' do
        expect {
          cart.add_item(product, 1)
        }.to change(CartItem, :count).by(1)
      end
    end

    context 'when product is already in cart' do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      it 'should update existing cart item quantity' do
        expect {
          cart.add_item(product, 1)
        }.not_to change(CartItem, :count)

        cart_item = cart.cart_items.find_by(product: product)
        expect(cart_item.quantity).to eq 2
      end
    end
  end
end
