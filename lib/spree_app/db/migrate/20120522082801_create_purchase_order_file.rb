class CreatePurchaseOrderFile < ActiveRecord::Migration
  def change
    create_table :spree_purchase_orders do |t|
      t.string :name

      t.timestamps
    end
  end
end
