class CreateSpreeLocations < ActiveRecord::Migration
  def self.up
    create_table :spree_locations do |t|
      t.string :name
      t.references :payment_method
      t.string :country

      t.timestamps
    end
  end

  def self.down
    drop_table :spree_locations
  end
end
