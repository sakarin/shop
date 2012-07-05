# This migration comes from spree_static_content (originally 20090829000527)
class AddIndexForPage < ActiveRecord::Migration
  def self.up
    add_index(:pages, :slug)
  end

  def self.down
    remove_index(:pages, :slug)
  end
end

