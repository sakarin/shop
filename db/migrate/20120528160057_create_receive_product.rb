class CreateReceiveProduct < ActiveRecord::Migration
  def change
    create_table :spree_receive_products do |t|
      t.string :number
      t.integer :purchase_order_id
      t.string :state

      t.timestamps
    end
  end
end
