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


    def add_variant(variant, quantity = 1, ad_hoc_option_value_ids=[], product_customizations=[])
      current_item = contains?(variant, ad_hoc_option_value_ids, product_customizations)
      if current_item
        current_item.quantity += quantity
        current_item.save
      else
        current_item = LineItem.new(:quantity => quantity)
        current_item.variant = variant

        # add the product_customizations, if any
        # TODO: is this an unnecessary step?
        product_customizations.map(&:save) # it is now safe to save the customizations we created in the OrdersController.populate

        current_item.product_customizations = product_customizations

        # find, and add the configurations, if any.  these have not been fetched from the db yet.              line_items.first.variant_id
        # we postponed it (performance reasons) until we actaully knew we needed them
        povs=[]
        ad_hoc_option_value_ids.each do |cid|
          povs << AdHocOptionValue.find(cid)
        end
        current_item.ad_hoc_option_values = povs

        # Hack product customizations for Name and Number
        # Hack By Dekpump
        current_item.price   = variant.price + povs.map(&:price_modifier).compact.sum + (product_customizations.map {|pc| pc.price(variant)}.sum == 6 ? 3 : product_customizations.map {|pc| pc.price(variant)}.sum    )

        self.line_items << current_item
      end

      # populate line_items attributes for additional_fields entries
      # that have populate => [:line_item]
      Variant.additional_fields.select{|f| !f[:populate].nil? && f[:populate].include?(:line_item) }.each do |field|
        value = ""

        if field[:only].nil? || field[:only].include?(:variant)
          value = variant.send(field[:name].gsub(" ", "_").downcase)
        elsif field[:only].include?(:product)
          value = variant.product.send(field[:name].gsub(" ", "_").downcase)
        end
        current_item.update_attribute(field[:name].gsub(" ", "_").downcase, value)
      end

      current_item
    end





  end
end