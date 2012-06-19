module Spree
  class ReceiveItem < ActiveRecord::Base
    # attr_accessible :title, :body
    attr_accessible :inventory_unit_id, :receive_product_id

    belongs_to :inventory_unit
    belongs_to :receive_product





  end
end
