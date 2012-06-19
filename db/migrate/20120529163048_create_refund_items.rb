class CreateRefundItems < ActiveRecord::Migration
  def change
    create_table :spree_refund_items do |t|
      t.integer :refund_id
      t.integer :inventory_unit_id

      t.timestamps
    end

    add_index :spree_refund_items, :refund_id, :name => 'index_refund_items_on_refund_id'
    add_index :spree_refund_items, :inventory_unit_id, :name => 'index_refund_items_on_inventory_unit_id'
  end
end
