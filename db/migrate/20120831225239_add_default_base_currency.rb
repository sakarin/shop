class AddDefaultBaseCurrency < ActiveRecord::Migration
  def change
    change_column :spree_orders, :base_currency, :string, :default => "GBP"
  end
end
