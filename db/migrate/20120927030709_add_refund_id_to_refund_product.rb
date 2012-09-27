class AddRefundIdToRefundProduct < ActiveRecord::Migration
  def change
    add_column :spree_refund_products, :refund_id, :integer
  end
end
