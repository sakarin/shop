module Spree
  class PurchaseItem < ActiveRecord::Base

    attr_accessible :inventory_unit_id, :purchase_order_id



    belongs_to :inventory_unit
    belongs_to :purchase_order

    after_create :determine_unit_po_version
    after_destroy :determine_unit_po_version






    private

    def determine_unit_po_version

      self.inventory_unit.update_attributes(:po_version =>  self.inventory_unit.purchase_items.size() || 0)
      if  self.inventory_unit.po_version.size() == 0
        self.inventory_unit.pending
      end
    end

  end
end