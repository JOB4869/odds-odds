class AddPasswordResetTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_reset_token, :string
    add_index :users, :password_reset_token, unique: true
  end
end
