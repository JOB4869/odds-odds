class Product < ApplicationRecord
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :buy_nows

  def sold?
    self.sold == true || buy_nows.where(status: :completed).exists?
  end

  def remaining_amount
    initial_amount = self.amount || 1
    sold_amount = buy_nows.where(status: :completed).sum(:amount)
    initial_amount - sold_amount
  end
end
