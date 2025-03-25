class DropEditAccountsTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :edit_accounts
  end

  def down
    create_table :edit_accounts do |t|
      t.bigint :user_id
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.text :address
      t.timestamps
    end
  end
end
