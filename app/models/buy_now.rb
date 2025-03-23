class BuyNow < ApplicationRecord
  belongs_to :user
  has_one_attached :proof_of_payment

  enum :status, { pending: 0, completed: 1 }, default: :pending

  after_update :update_beer_balance, if: :completed?

  private

  def update_beer_balance
    if status_previously_changed? && completed?
      user.increment!(:beer_balance, amount)
    end
  end
end
