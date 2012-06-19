class CreateRefundProducts < ActiveRecord::Migration
  def change
    create_table :spree_refund_products do |t|
      t.string :number
      t.string :state
      t.decimal  :amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.string :order_id

      t.timestamps
    end

    add_column :spree_inventory_units, :refund_product_id, :integer

  end
end
