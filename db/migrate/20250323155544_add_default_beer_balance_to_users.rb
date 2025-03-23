class AddDefaultBeerBalanceToUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :beer_balance, :integer, default: 0
  end
end
