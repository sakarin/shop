class AddTitleToTaxon < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :title, :string
  end
end
