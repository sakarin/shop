class AddTitleToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :title, :string
  end
end
