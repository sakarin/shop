module Spree
  Order.class_eval do

    def available_shipping_methods(display_on = nil)
      ShippingMethod.all
    end

    def generate_order_number
      record = true
      while record
        random = "R#{SecureRandom.hex(3).to_s.upcase}"
        record = self.class.where(:number => random).first
      end
      self.number = random if self.number.blank?
      self.number
    end

    #def rate_hash
    #  @rate_hash ||= available_shipping_methods(:front_end).collect do |ship_method|
    #    next unless cost = ship_method.calculator.compute(self)
    #
    #    # calculator_free_shipping -----------------------------------
    #    #-------------------------------------------------------------
    #
    #    number_of_free_shipment = 0
    #    (self.line_items || []).each do |item|
    #      next if item.product.shipping_category.nil?
    #       if item.product.shipping_category.name == Spree::Config[:free_shipment_text]
    #         number_of_free_shipment = number_of_free_shipment + 1
    #       end
    #
    #    end
    #
    #    if number_of_free_shipment == self.line_items.size
    #      cost = 0
    #    elsif number_of_free_shipment > 0
    #      cost = cost - (number_of_free_shipment) * Spree::Config[:additional_item_shipping_cost]
    #    end
    #    #-------------------------------------------------------------
    #
    #    ShippingRate.new(:id => ship_method.id,
    #                     :shipping_method => ship_method,
    #                     :name => ship_method.name,
    #                     :cost => cost)
    #  end.compact.sort_by { |r| r.cost }
    #end



  end
end