class User < ApplicationRecord
  has_many :buy_nows
  has_many :products
  has_one_attached :qr_code

  has_secure_password

  validates :email,
            presence: { message: "กรุณากรอกอีเมล" },
            uniqueness: { message: "อีเมลนี้ถูกใช้งานแล้ว" },
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "รูปแบบอีเมลไม่ถูกต้อง" }

  validates :password,
            presence: { message: "กรุณากรอกรหัสผ่าน" },
            length: { minimum: 8, maximum: 16, message: "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร" },
            format: {
              with: /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~])[A-Za-z\d!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~]{8,16}\z/,
              message: "รหัสผ่านต้องประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ"
            },
            on: :create

  validates :beer_balance, numericality: { greater_than_or_equal_to: 0, message: "ต้องมากกว่าหรือเท่ากับ 0" }

  def deposit(amount)
    return false if amount <= 0
    increment!(:beer_balance, amount)
  end

  def withdraw(amount)
    return false if amount <= 0 || amount > beer_balance
    decrement!(:beer_balance, amount)
  end

  def drink_beer
    if beer_balance > 0
      update(beer_balance: beer_balance - 1)
      true
    else
      false
    end
  end

  validates :first_name,
            presence: { message: "กรุณากรอกชื่อ" },
            format: { with: /\A[ก-ฮ\u0E30-\u0E3A\u0E40-\u0E4E a-zA-Z]+\z/, message: "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ" },
            on: :update

  validates :last_name,
            presence: { message: "กรุณากรอกนามสกุล" },
            format: { with: /\A[ก-ฮ\u0E30-\u0E3A\u0E40-\u0E4E a-zA-Z]+\z/, message: "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ" },
            on: :update

  validates :phone,
            presence: { message: "กรุณาเบอร์โทรศัพท์" },
            length: { minimum: 10, maximum: 10 },
            format: { with: /\d{10}/, message: "เบอร์โทรศัพท์ 10 หลัก" },
            on: :update

  validates :prompt_pay,
            presence: { message: "กรุณากรอกพร้อมเพย์" },
            format: { with: /\A\d{10}\z|\A\d{13}\z/, message: "หมายเลขโทรศัพท์ 10 หลัก, หมายเลขบัตรประชาชน 13 หลัก" },
            on: :update

  validates :address,
            presence: { message: "กรุณากรอกที่อยู่" },
            on: :update

  before_create :set_default_beer_balance

  private

  def set_default_beer_balance
    self.beer_balance = 0 if beer_balance.nil?
  end
end
