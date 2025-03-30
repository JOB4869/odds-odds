class Account < ApplicationRecord
  belongs_to :user

  validates :first_name,
            presence: { message: "กรุณากรอกชื่อ" },
            format: { with: /\A[ก-ฮ\u0E30-\u0E3A\u0E40-\u0E4E a-zA-Z]+\z/, message: "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ" }

  validates :last_name,
            presence: { message: "กรุณากรอกนามสกุล" },
            format: { with: /\A[ก-ฮ\u0E30-\u0E3A\u0E40-\u0E4E a-zA-Z]+\z/, message: "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ" }

  validates :phone,
            presence: { message: "กรุณาเบอร์โทรศัพท์" },
            length: { minimum: 10, maximum: 10 },
            format: { with: /\d{10}/, message: "เบอร์โทรศัพท์ 10 หลัก" }

  validates :prompt_pay,
            presence: { message: "กรุณากรอกพร้อมเพย์" },
            format: { with: /\A\d{10}\z|\A\d{13}\z/, message: "หมายเลขโทรศัพท์ 10 หลัก, หมายเลขบัตรประชาชน 13 หลัก" }

  validates :address,
            presence: { message: "กรุณากรอกที่อยู่" }
end
