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




  end
end