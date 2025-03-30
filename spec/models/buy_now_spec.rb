require 'rails_helper'

RSpec.describe BuyNow, type: :model do
  let(:user) { create(:user) }
  let(:product) { create(:product, price: 100) }

  describe 'validations' do
    it 'should validate presence of user' do
      buy_now = BuyNow.new(product: product, amount: 1)
      expect(buy_now).not_to be_valid
      expect(buy_now.errors[:user]).to include("can't be blank")
    end

    it 'should validate presence of product' do
      buy_now = BuyNow.new(user: user, amount: 1)
      expect(buy_now).not_to be_valid
      expect(buy_now.errors[:product]).to include("can't be blank")
    end

    it 'should validate presence of amount' do
      buy_now = BuyNow.new(user: user, product: product)
      expect(buy_now).not_to be_valid
      expect(buy_now.errors[:amount]).to include("can't be blank")
    end

    it 'should validate amount is greater than 0' do
      buy_now = BuyNow.new(user: user, product: product, amount: 0)
      expect(buy_now).not_to be_valid
      expect(buy_now.errors[:amount]).to include("must be greater than 0")
    end
  end

  describe 'associations' do
    it 'should belong to user' do
      buy_now = BuyNow.reflect_on_association(:user)
      expect(buy_now.macro).to eq :belongs_to
    end

    it 'should belong to product' do
      buy_now = BuyNow.reflect_on_association(:product)
      expect(buy_now.macro).to eq :belongs_to
    end
  end

  describe '#total_price' do
    let(:buy_now) { create(:buy_now, user: user, product: product, amount: 2) }

    it 'should calculate total price correctly' do
      expect(buy_now.total_price).to eq 200
    end
  end

  describe '#process_purchase' do
    context 'when user has sufficient balance' do
      before do
        user.deposit(300)
      end

      it 'should deduct money from user account' do
        buy_now = create(:buy_now, user: user, product: product, amount: 2)
        expect {
          buy_now.process_purchase
        }.to change(user, :beer_balance).by(-200)
      end

      it 'should return true' do
        buy_now = create(:buy_now, user: user, product: product, amount: 2)
        expect(buy_now.process_purchase).to be true
      end
    end

    context 'when user has insufficient balance' do
      before do
        user.deposit(50)
      end

      it 'should not deduct money from user account' do
        buy_now = create(:buy_now, user: user, product: product, amount: 2)
        expect {
          buy_now.process_purchase
        }.not_to change(user, :beer_balance)
      end

      it 'should return false' do
        buy_now = create(:buy_now, user: user, product: product, amount: 2)
        expect(buy_now.process_purchase).to be false
      end
    end
  end
end
