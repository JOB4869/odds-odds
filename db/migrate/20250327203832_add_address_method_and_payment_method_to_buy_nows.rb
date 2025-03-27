class AddAddressMethodAndPaymentMethodToBuyNows < ActiveRecord::Migration[8.0]
  def change
    add_column :buy_nows, :address_method, :integer
    add_column :buy_nows, :payment_method, :integer
  end
end
