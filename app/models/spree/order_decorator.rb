module Spree
  Order.class_eval do

    has_many :refunds, :dependent => :destroy


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

    def available_payment_methods

      user = self.user
      #user = Spree::User.find(17601)
      item_count = 0
      is_vip = false
      time = Time.local(2012, 10, 5, 17, 35)

      (user.orders || []).each do |order|
        next unless (order.state == "complete" and order.created_at > time)
        item_count += order.inventory_units.size
        if order.inventory_units.size >= 10
          is_vip = ture
        end
      end

      if user.vip.blank? && (item_count > 2  && item_count < 6)
        user.vip = "normal"
        user.vip_at = Time.now
        user.save
        user.reload
      end

      if user.vip.blank? && (item_count >= 5 || is_vip == true)
        user.vip = "vip"
        user.vip_at = Time.now
        user.save
        user.reload
      end

      if user.vip == "vip" && (user.vip_at + 1.months < Date.today)
        user.vip = "vip_plus"
        user.save
        user.reload
      end

      country_code = Geokit::Geocoders::MultiGeocoder.geocode(user.current_sign_in_ip).country_code
      @available_payment_methods = []

      if user.vip == "vip"
        @available_payment_methods = Spree::PaymentMethod.where(:account_type => "vip")
      elsif user.vip == "vip_plus"
        @available_payment_methods = Spree::PaymentMethod.where(:account_type => "vip_plus")
      elsif user.vip == "normal" && !Spree::PaymentMethod.where(:account_type => "normal", :account_for_location => "#{country_code}").blank?
        @available_payment_methods = Spree::PaymentMethod.where(:account_type => "normal", :account_for_location => "#{country_code}")
      else
        unless Spree::PaymentMethod.where("account_type LIKE 'test' AND account_for_location LIKE '%#{country_code}%'").blank?
          @available_payment_methods = Spree::PaymentMethod.where("account_type LIKE 'test' AND account_for_location LIKE '%#{country_code}%'")

        else
          @available_payment_methods = Spree::PaymentMethod.where(:account_type => "suspend")
        end
      end
      @available_payment_methods
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
        current_item.price = variant.price + povs.map(&:price_modifier).compact.sum + Spree::Currency.conversion_to_current(product_customizations.map { |pc| pc.price(variant) }.sum == 6 ? 3 : product_customizations.map { |pc| pc.price(variant) }.sum)

        self.line_items << current_item
      end

      # populate line_items attributes for additional_fields entries
      # that have populate => [:line_item]
      Variant.additional_fields.select { |f| !f[:populate].nil? && f[:populate].include?(:line_item) }.each do |field|
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

    private
    def update_shipment_state
      self.shipment_state =
          case shipments.count
            when 0
              nil
            when shipments.shipped.count
              'shipped'
            when shipments.ready.count
              'ready'
            when shipments.pending.count
              'pending'
            when shipments.packet.count
              'packet'
            else
              'partial'
          end
      self.shipment_state = 'backorder' if backordered?

      if old_shipment_state = self.changed_attributes['shipment_state']
        self.state_changes.create({
                                      :previous_state => old_shipment_state,
                                      :next_state => self.shipment_state,
                                      :name => 'shipment',
                                      :user_id => (User.respond_to?(:current) && User.current && User.current.id) || self.user_id
                                  }, :without_protection => true)
      end
    end


  end
end