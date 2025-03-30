class BuyNow < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_one_attached :proof_of_payment

  validates :user, presence: true
  validates :product, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  enum :status, { pending: 0, completed: 1 }, default: :pending
  enum :address_method, { current_address: 0, tipco_address: 1 }
  enum :payment_method, { promptpay: 0, cash_on_delivery: 1 }

  validates :original_amount, presence: true, on: :update

  before_create :set_original_amount
  after_update :update_beer_balance, if: :completed?

  def total_price
    if product&.name == "เบียร์ ODDS" && amount >= 3
      100  # ราคาพิเศษเมื่อซื้อ 3 แก้ว
    else
      product.price * amount
    end
  end

  def process_purchase
    return false if total_price > user.beer_balance

    if user.withdraw(total_price)
      update(status: "completed")
      true
    else
      false
    end
  end

  private

  def set_original_amount
    self.original_amount = amount
  end

  def update_beer_balance
    if status_previously_changed? && status_was == "pending" && completed? && product_id.nil?
      user.increment!(:beer_balance, amount)
    end
  end
end
