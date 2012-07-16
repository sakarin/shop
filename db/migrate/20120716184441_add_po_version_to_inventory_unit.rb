class AddPoVersionToInventoryUnit < ActiveRecord::Migration
  def change
    add_column :spree_inventory_units, :po_version, :integer
  end
end
