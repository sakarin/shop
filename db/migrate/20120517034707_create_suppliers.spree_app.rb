# This migration comes from spree_app (originally 20120517033009)
class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :spree_suppliers do |t|
      t.string :code
      t.string :name
      t.string :email
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
