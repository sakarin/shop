module Spree
  class Calculator::FlexiRate < Calculator
    preference :first_item,      :decimal, :default => 0.0
    preference :additional_item, :decimal, :default => 0.0
    preference :max_items,       :integer, :default => 0

    attr_accessible :preferred_first_item, :preferred_additional_item, :preferred_max_items

    def self.description
      I18n.t(:flexible_rate)
    end

    def self.available?(object)
      true
    end

    def compute(object)
      sum = 0
      max = self.preferred_max_items.to_i
      items_count = object.line_items.map(&:quantity).sum
      items_count.times do |i|
        # check max value to avoid divide by 0 errors
        if (max == 0 && i == 0) || (max > 0) && (i % max == 0)
          sum += self.preferred_first_item.to_f
        else
          sum += self.preferred_additional_item.to_f
        end
      end

      #-------------------------------------------------------------------------------------------------------
      #- Compute Free Shipping Item
      free_shipment_items_count = 0
      free_cost = 0
      (object.line_items || []).each do |item|
        next if item.product.shipping_category.nil?
        if item.product.shipping_category.name == Spree::Config[:free_shipment_text]
          free_shipment_items_count = free_shipment_items_count + item.quantity
        end
      end
      free_cost = free_shipment_items_count * Spree::Config[:additional_item_shipping_cost]
      sum = sum - free_cost
      if free_shipment_items_count == object.line_items.map(&:quantity).sum
        sum = 0
      end
      #-------------------------------------------------------------------------------------------------------

      sum
    end
  end
end
