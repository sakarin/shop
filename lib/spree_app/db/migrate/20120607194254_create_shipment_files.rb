class CreateShipmentFiles < ActiveRecord::Migration
  def change
    create_table :spree_shipment_files do |t|
      t.string :name

      t.timestamps
    end
  end
end
