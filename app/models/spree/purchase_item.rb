module Spree
  class PurchaseItem < ActiveRecord::Base

    attr_accessible :inventory_unit_id, :purchase_order_id, :last_purchase_order_id


    belongs_to :inventory_unit
    belongs_to :purchase_order

    after_create :determine_unit_po_version
    after_destroy :determine_unit_po_version

    #before_destroy :determine_last_purchase_order_id


    private

    def determine_unit_po_version

      self.inventory_unit.update_attributes(:po_version => self.inventory_unit.purchase_items.size() || 0)
      if  self.inventory_unit.po_version.size() == 0
        self.inventory_unit.pending
      end
      determine_last_purchase_order_id
    end


    def determine_last_purchase_order_id
      @items = PurchaseItem.find_by_sql("SELECT * FROM spree_purchase_items WHERE inventory_unit_id = #{self.inventory_unit_id} ORDER BY id DESC")
      @items.each do |item|
        @purchase_item = Spree::PurchaseItem.find_by_sql("SELECT * FROM spree_purchase_items WHERE inventory_unit_id = #{item.inventory_unit_id} AND id < #{item.id} ORDER BY id DESC").first
        unless @purchase_item.nil?
          item.update_attributes(:last_purchase_order_id => @purchase_item.purchase_order_id )
        end
      end

    end

  end
end