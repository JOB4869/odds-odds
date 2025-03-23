class CreateBuyNows < ActiveRecord::Migration[8.0]
  def change
    create_table :buy_nows do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount
      t.string :status
      t.string :proof_of_payment

      t.timestamps
    end
  end
end
