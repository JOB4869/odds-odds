class AddOriginalAmountToBuyNows < ActiveRecord::Migration[8.0]
  def change
    add_column :buy_nows, :original_amount, :integer
    BuyNow.update_all('original_amount = amount')
  end
end
