class AddAllowUserLogin < ActiveRecord::Migration
  def change
    add_column :spree_stores, :allow_user_login, :boolean, :default => true
  end
end
