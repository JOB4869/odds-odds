class Product < ApplicationRecord
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :buy_nows

  validates :name, presence: { message: "กรุณากรอกชื่อสินค้า" }
  validates :price, presence: { message: "กรุณากรอกราคา" }
  validates :price, numericality: { greater_than_or_equal_to: 0, message: "ต้องมากกว่าหรือเท่ากับ 0" }

  def sold?
    self.sold == true || buy_nows.where(status: :completed).exists?
  end

  def remaining_amount
    initial_amount = self.amount || 1
    sold_amount = buy_nows.where(status: :completed).sum(:amount)
    initial_amount - sold_amount
  end
end
