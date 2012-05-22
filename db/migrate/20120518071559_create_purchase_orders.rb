class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :spree_purchase_orders do |t|
      t.string :number
      t.integer :supplier_id
      t.string :state

      t.timestamps
    end

    add_index :spree_purchase_orders, :supplier_id, :name => 'index_purchase_orders_on_supplier_id'

  end
end
