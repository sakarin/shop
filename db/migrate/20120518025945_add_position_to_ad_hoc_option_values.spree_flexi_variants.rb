# This migration comes from spree_flexi_variants (originally 20111123031035)
class AddPositionToAdHocOptionValues < ActiveRecord::Migration
  def self.up
    add_column :ad_hoc_option_values, :position, :integer
  end

  def self.down
    remove_column :ad_hoc_option_values, :position
  end
end
