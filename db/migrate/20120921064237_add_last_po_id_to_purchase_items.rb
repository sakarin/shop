class AddLastPoIdToPurchaseItems < ActiveRecord::Migration
  def change
    add_column :spree_purchase_items, :last_purchase_order_id, :integer, :default => 0, :null => false
  end
end
