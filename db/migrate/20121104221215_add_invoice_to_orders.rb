class AddInvoiceToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :invoice, :string, :default => ""
  end
end
