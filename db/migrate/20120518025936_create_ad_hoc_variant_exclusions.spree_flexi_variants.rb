# This migration comes from spree_flexi_variants (originally 20110317205336)
class CreateAdHocVariantExclusions < ActiveRecord::Migration
  def self.up
    create_table :ad_hoc_variant_exclusions do |t|
      t.integer :product_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ad_hoc_variant_exclusions
  end
end
