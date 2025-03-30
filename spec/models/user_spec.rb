require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'should validate presence of email' do
      user = User.new(password: 'Password123!')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("กรุณากรอกอีเมล")
    end

    it 'should validate presence of password' do
      user = User.new(email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("กรุณากรอกรหัสผ่าน")
    end

    it 'should validate email format' do
      user = User.new(email: 'invalid-email', password: 'Password123!')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("รูปแบบอีเมลไม่ถูกต้อง")
    end

    it 'should validate password format' do
      user = User.new(email: 'test@example.com', password: '123')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร")
    end
  end

  describe '#drink_beer' do
    let(:user) { build(:user, beer_balance: 1) }

    it 'should decrease beer balance by 1' do
      expect {
        user.drink_beer
      }.to change(user, :beer_balance).by(-1)
    end

    it 'should return true when beer balance is greater than 0' do
      expect(user.drink_beer).to be true
    end

    it 'should return false when beer balance is 0' do
      user.beer_balance = 0
      expect(user.drink_beer).to be false
    end
  end
end
