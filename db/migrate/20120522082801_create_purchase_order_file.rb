class CreatePurchaseOrderFile < ActiveRecord::Migration
  def change
    create_table :spree_purchase_order_files do |t|
      t.string :name

      t.timestamps
    end
  end
end
