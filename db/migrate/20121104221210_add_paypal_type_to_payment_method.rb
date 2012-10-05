class AddPaypalTypeToPaymentMethod < ActiveRecord::Migration
  def change
    add_column :spree_payment_methods, :account_type, :string
    add_column :spree_payment_methods, :account_for_location, :string
  end
end
