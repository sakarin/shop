module Spree
  class PurchaseItem < ActiveRecord::Base

    attr_accessible :inventory_unit_id, :purchase_order_id


    belongs_to :inventory_unit
    belongs_to :purchase_order
  end
end