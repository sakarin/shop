class EditRefunds < ActiveRecord::Migration
  def change
    rename_column :spree_refunds, :purchase_order_id, :order_id
  end

end

