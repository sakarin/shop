class CreateReceiveItem < ActiveRecord::Migration
  def change
    create_table :spree_receive_items do |t|
      t.integer :receive_product_id
      t.integer :inventory_unit_id

      t.timestamps
    end

    add_index :spree_receive_items, :receive_product_id, :name => 'index_receive_items_on_receive_product_id'
    add_index :spree_receive_items, :inventory_unit_id, :name => 'index_receive_items_on_inventory_unit_id'
  end
end
