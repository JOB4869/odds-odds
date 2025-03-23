class AddBeerBalanceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :beer_balance, :integer
  end
end
