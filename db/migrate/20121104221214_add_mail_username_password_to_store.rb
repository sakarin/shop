class AddMailUsernamePasswordToStore < ActiveRecord::Migration
  def change

    add_column :spree_stores, :mail_username, :string, :default => ""
    add_column :spree_stores, :mail_password, :string, :default => ""
  end
end
