require 'rails_helper'

RSpec.describe BuyNow, type: :model do
  let(:user) { create(:user) }
  let(:product) { create(:product, price: 100) }

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
end
