class User < ApplicationRecord
  has_many :buy_nows
  validates :beer_balance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def drink_beer
    return false if beer_balance <= 0
    decrement!(:beer_balance)
  end

  has_secure_password

  validates :email, presence: { message: "กรุณากรอกอีเมล" },
                   uniqueness: { message: "อีเมลนี้ถูกใช้งานแล้ว" },
                   format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "รูปแบบอีเมลไม่ถูกต้อง" }

  validates :password, presence: { message: "กรุณากรอกรหัสผ่าน" },
                      length: { minimum: 8, maximum: 16, message: "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร" },
                      format: {
                        with: /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~])[A-Za-z\d!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~]{8,16}\z/,
                        message: "รหัสผ่านต้องประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ"
                      }

  before_create :set_default_beer_balance

  private

  def set_default_beer_balance
    self.beer_balance = 0 if beer_balance.nil?
  end
end
