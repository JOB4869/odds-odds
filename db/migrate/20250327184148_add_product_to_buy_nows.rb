class AddProductToBuyNows < ActiveRecord::Migration[8.0]
  def change
    add_reference :buy_nows, :product, foreign_key: true
  end
end
