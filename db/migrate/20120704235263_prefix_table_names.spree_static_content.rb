# This migration comes from spree_static_content (originally 20111201184855)
class PrefixTableNames < ActiveRecord::Migration
  def change
    rename_table :pages, :spree_pages
  end
end
