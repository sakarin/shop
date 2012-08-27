class AddVipForStore < ActiveRecord::Migration
  def change
    add_column :spree_stores, :shop_for_vip, :boolean, :default => false
  end
end
