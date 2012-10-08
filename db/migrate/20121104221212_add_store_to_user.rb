class AddStoreToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :store_id, :integer
  end
end
