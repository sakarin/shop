class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :spree_refunds do |t|
      t.string :number
      t.integer :purchase_order_id
      t.string :state

      t.timestamps
    end
  end
end
