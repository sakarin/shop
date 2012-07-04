class AddCurrencyToOrder < ActiveRecord::Migration
  def self.up
    if table_exists?('orders')
      add_column :orders, :base_currency, :string
    elsif table_exists?('spree_orders')
      add_column :spree_orders, :base_currency, :string
    end
  end

  def self.down
    if table_exists?('orders')
      remove_column :orders, :base_currency
    elsif table_exists?('spree_orders')
      remove_column :spree_orders, :base_currency
    end
  end
end
