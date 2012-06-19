module Spree
  class RefundItem < ActiveRecord::Base
    # attr_accessible :title, :body

    attr_accessible :inventory_unit_id, :refund_id

    belongs_to :inventory_unit
    belongs_to :refund
  end
end
