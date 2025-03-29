class BuyNow < ApplicationRecord
  belongs_to :user
  belongs_to :product, optional: true
  has_one_attached :proof_of_payment

  enum :status, { pending: 0, completed: 1 }, default: :pending
  enum :address_method, { current_address: 0, tipco_address: 1 }
  enum :payment_method, { promptpay: 0, cash_on_delivery: 1 }

  before_create :set_original_amount
  after_update :update_beer_balance, if: :completed?

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
