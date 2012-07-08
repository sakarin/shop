class AddShirtPropertiesToInventoryUnit < ActiveRecord::Migration
  def change

    add_column :spree_inventory_units, :season, :string, :default => "", :limit => 10
    add_column :spree_inventory_units, :team, :string, :default => "", :limit => 50
    add_column :spree_inventory_units, :shirt_type, :string, :default => "", :limit => 20
    add_column :spree_inventory_units, :name, :string, :default => "", :limit => 15
    add_column :spree_inventory_units, :number, :string, :default => "", :limit => 2
    add_column :spree_inventory_units, :size, :string, :default => "", :limit => 15
    add_column :spree_inventory_units, :patch, :string, :default => "", :limit => 100
    add_column :spree_inventory_units, :sleeve, :string, :default => "", :limit => 10

    add_column :spree_inventory_units, :po_version, :integer

  end
end
