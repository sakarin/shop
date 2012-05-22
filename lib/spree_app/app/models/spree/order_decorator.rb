module Spree
  Order.class_eval do

    def available_shipping_methods(display_on = nil)
      ShippingMethod.all
    end
  end
end