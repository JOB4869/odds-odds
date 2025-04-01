class Product < ApplicationRecord
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :buy_nows

  validates :name, presence: { message: "กรุณากรอกชื่อสินค้า" }
  validates :price, presence: { message: "กรุณากรอกราคา" }
  validates :price, numericality: { greater_than_or_equal_to: 0, message: "ต้องมากกว่าหรือเท่ากับ 0" }

  def sold?
    return false if name == "เบียร์ ODDS"
    self.sold == true || buy_nows.where(status: :completed).exists?
  end

  def remaining_amount
    Rails.logger.info "Calculating remaining_amount for Product ID: #{id}"
    if name == "เบียร์ ODDS"
      Rails.logger.info "Product is เบียร์ ODDS, returning Infinity"
      return Float::INFINITY
    end
    initial_amount = self.amount || 1
    Rails.logger.info "Initial amount: #{initial_amount}"
    # โหลด completed buy_nows มาเก็บในตัวแปร เพื่อดู count และ sum
    completed_buy_nows = buy_nows.where(status: :completed)
    sold_amount = completed_buy_nows.sum(:amount)
    Rails.logger.info "Completed BuyNows count: #{completed_buy_nows.count}, Sold amount sum: #{sold_amount}"
    result = initial_amount - sold_amount
    Rails.logger.info "Calculated remaining amount: #{result}"
    result
  end
end
