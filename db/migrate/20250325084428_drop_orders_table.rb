class DropOrdersTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :orders
  end

  def down
    create_table :orders do |t|
      t.bigint :user_id, null: false
      t.integer :amount
      t.string :status
      t.string :proof_of_payment
      t.timestamps
    end

    add_index :orders, :user_id
  end
end
