class AddPromptPayToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :prompt_pay, :string
  end
end
