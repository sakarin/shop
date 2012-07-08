class AddSeoTitleToStore < ActiveRecord::Migration
  def change
    change_table :spree_stores do |t|
      t.text :seo_title
    end
  end
end
