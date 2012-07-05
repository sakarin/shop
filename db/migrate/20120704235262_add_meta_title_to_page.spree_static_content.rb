# This migration comes from spree_static_content (originally 20110717103112)
class AddMetaTitleToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :meta_title, :string
  end

  def self.down
    remove_column :pages, :meta_title
  end
end
