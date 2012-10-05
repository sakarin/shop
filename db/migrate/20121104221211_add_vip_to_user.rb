class AddVipToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :vip, :string, :default => ''
    add_column :spree_users, :vip_at, :datetime
  end
end
