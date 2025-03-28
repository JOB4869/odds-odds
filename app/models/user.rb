class User < ApplicationRecord
  has_many :buy_nows
  has_many :products
  has_one_attached :qr_code

  validates :beer_balance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def drink_beer
    return false if beer_balance <= 0

    decrement!(:beer_balance)
  end

  has_secure_password

  validates :email,
            presence: { message: "กรุณากรอกอีเมล" },
            uniqueness: { message: "อีเมลนี้ถูกใช้งานแล้ว" },
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "รูปแบบอีเมลไม่ถูกต้อง" },
            on: :create

  validates :password,
            presence: { message: "กรุณากรอกรหัสผ่าน" },
            length: { minimum: 8, maximum: 16, message: "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร" },
            format: {
              with: /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~])[A-Za-z\d!"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~]{8,16}\z/,
              message: "รหัสผ่านต้องประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ"
            },
            if: -> { password.present? },
            on: [ :create, :password_reset ]

  validates :first_name,
            presence: { message: "กรุณากรอกชื่อ" },
            format: { with: /\A[ก-ฮ\u0E30-\u0E3A\u0E40-\u0E4E a-zA-Z]+\z/, message: "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ" },
            on: :update_profile

  validates :last_name,
            presence: { message: "กรุณากรอกนามสกุล" },
            format: { with: /\A[ก-ฮ\u0E30-\u0E3A\u0E40-\u0E4E a-zA-Z]+\z/, message: "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ" },
            on: :update_profile

  validates :address, presence: { message: "กรุณากรอกที่อยู่" }, on: :update_profile

  validates :phone,
            presence: { message: "กรุณาเบอร์โทรศัพท์" },
            length: { minimum: 10, maximum: 10 },
            format: { with: /\A\d{10}\z/, message: "เบอร์โทรศัพท์ 10 หลัก" },
            on: :update_profile

  validates :prompt_pay,
            presence: { message: "กรุณากรอกพร้อมเพย์" },
            length: { minimum: 10, maximum: 13 },
            format: { with: /\A\d{10}|\d{13}\z/, message: "หมายเลขโทรศัพท์ 10 หลัก, หมายเลขบัตรประชาชน 13 หลัก" },
            on: :update_profile

  before_create :set_default_beer_balance

  private

  def set_default_beer_balance
    self.beer_balance = 0 if beer_balance.nil?
  end
end
