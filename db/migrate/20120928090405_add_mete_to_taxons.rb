class AddMeteToTaxons < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :meta_description, :string
    add_column :spree_taxons, :meta_keywords, :string
  end
end
