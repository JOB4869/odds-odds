class User < ApplicationRecord
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
end
