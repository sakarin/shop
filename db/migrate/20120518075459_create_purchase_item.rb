class CreatePurchaseItem < ActiveRecord::Migration
  def change
    create_table :spree_purchase_items do |t|
      t.integer :purchase_order_id
      t.integer :inventory_unit_id

      t.timestamps
    end

    add_index :spree_purchase_items, :purchase_order_id, :name => 'index_purchase_items_on_purchase_order_id'
    add_index :spree_purchase_items, :inventory_unit_id, :name => 'index_purchase_items_on_inventory_unit_id'

  end
end
