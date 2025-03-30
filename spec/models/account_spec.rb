require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'should validate beer_balance is greater than or equal to 0' do
      user = User.new(email: 'test@example.com', beer_balance: -1)
      expect(user).not_to be_valid
      expect(user.errors[:beer_balance]).to include("ต้องมากกว่าหรือเท่ากับ 0")
    end
  end

  describe '#beer_balance' do
    let(:user) { User.create(email: 'test@example.com', beer_balance: 0) }

    it 'should initialize with zero balance' do
      expect(user.beer_balance).to eq 0
    end
  end

  describe '#deposit' do
    let(:user) { User.create(email: 'test@example.com', beer_balance: 0) }

    it 'should increase balance by specified amount' do
      expect {
        user.deposit(100)
      }.to change(user, :beer_balance).by(100)
    end

    it 'should not allow negative deposit' do
      expect {
        user.deposit(-100)
      }.not_to change(user, :beer_balance)
    end
  end

  describe '#withdraw' do
    let(:user) { User.create(email: 'test@example.com', beer_balance: 100) }

    it 'should decrease balance by specified amount' do
      expect {
        user.withdraw(50)
      }.to change(user, :beer_balance).by(-50)
    end

    it 'should not allow withdrawal more than balance' do
      expect {
        user.withdraw(150)
      }.not_to change(user, :beer_balance)
    end

    it 'should not allow negative withdrawal' do
      expect {
        user.withdraw(-50)
      }.not_to change(user, :beer_balance)
    end
  end
end
