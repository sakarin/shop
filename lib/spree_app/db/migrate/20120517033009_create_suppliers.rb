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
