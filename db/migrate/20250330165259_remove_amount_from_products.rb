class RemoveAmountFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :amount, :integer
  end
end
