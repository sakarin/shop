class CreatePagesStores < ActiveRecord::Migration
  def self.up
    create_table :spree_pages_stores, :id => false do |t|
      t.references :page
      t.references :store
      t.timestamps
    end
  end

  def self.down
    drop_table :spree_pages_stores
  end
end
