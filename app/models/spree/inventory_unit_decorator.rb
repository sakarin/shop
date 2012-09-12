module Spree
  InventoryUnit.class_eval do

    attr_accessible :po_version, :refund_product_id, :state

    has_many :purchase_items
    has_many :purchase_orders, :through => :purchase_items

    has_many :receive_items
    has_many :receive_products, :through => :receive_items

    has_many :refund_items
    has_many :refunds, :through => :refund_items

    scope :packet, where(:state => 'packet')
    scope :pending, where(:state => 'pending')

    scope :backorder_inventory_units, where("state LIKE 'backordered' AND po_version = 0").select("id, count(variant_id) as quantity, po_version, variant_id, name, number, size, patch, season, team, shirt_type, sleeve, state").group('variant_id, name, number, size, patch, season, team, shirt_type, sleeve')

    scope :pending_inventory_units, where("state LIKE 'backordered' AND po_version > 0 ").select("id, count(variant_id) as quantity, po_version, variant_id, name, number, size, patch, season, team, shirt_type, sleeve, state").group('variant_id, name, number, size, patch, season, team, shirt_type, sleeve')


    # state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'backordered' do

      event :pending do
        transition :to => 'backordered', :from => 'purchased'

      end

      event :fill_backorder do
        transition :from => ['backordered', 'sold'], :to => 'purchased'
      end

      event :sold do
        transition :from => ['purchased', 'backordered'], :to => 'sold'
      end
      event :pack do
        transition :from => 'sold', :to => 'packet'
      end

      event :ship do
        transition :to => 'shipped', :if => :allow_ship?
      end
      event :refund do
        transition :from => 'backordered', :to => 'refund'
      end

      event :return do
        transition :from => 'shipped', :to => 'returned'
      end

      after_transition :on => :fill_backorder, :do => :update_order
      after_transition :on => :refund, :do => :after_refund
    end


    # Assigns inventory to a newly completed order.
    # Should only be called once during the life-cycle of an order, on transition to completed.
    #
    def self.assign_opening_inventory(order)
      return [] unless order.completed?

      #increase inventory to meet initial requirements
      order.line_items.each do |line_item|
        increase(order, line_item.variant, line_item.quantity, line_item)
      end
    end

    #def self.increase(order, variant, quantity, line_item)
    #  back_order = 0
    #  sold = 0
    #  if !line_item.product.shipping_category.nil? && line_item.product.shipping_category.name == Spree::Config[:free_shipment_text]
    #    sold = quantity
    #  else
    #    back_order = quantity
    #  end
    #  #create units if configured
    #  if Spree::Config[:create_inventory_units]
    #    create_units(order, variant, sold, back_order, line_item)
    #  end
    #end

    def self.increase(order, variant, quantity, line_item)
      back_order = quantity
      sold = quantity - back_order

      #create units if configured
      if Spree::Config[:create_inventory_units]
        create_units(order, variant, sold, back_order, line_item)
      end
    end

    def after_refund
      self.shipment = nil
      self.save
    end

    def allow_ship?
      #self.packet? && !self.shipment.tracking.nil?
      self.packet?
    end


    # -------------------------------------------------------------------------------------
    # create inventory units
    # -------------------------------------------------------------------------------------
    def self.create_units(order, variant, sold, back_order, item)
      return if back_order > 0 && !Spree::Config[:allow_backorders]

      shipment = order.shipments.detect { |shipment| !shipment.shipped? }

      attr_accessible :shipment

      #------------------------------------------------------------------------------------------
      # option name
      #------------------------------------------------------------------------------------------
      option_name = ''
      item.product_customizations.each do |customization|
        next if customization.customized_product_options.all? { |cpo| cpo.value.empty? }
        if customization.product_customization_type.name.downcase == 'shirt-name'
          customization.customized_product_options.each do |option|
            next if option.value.empty?
            option_name = option.value
          end
        end
      end

      if option_name.empty?
        unless item.variant.product.product_properties.empty?
          for product_property in item.variant.product.product_properties
            if product_property.property.presentation.downcase == "shirt-name"
              option_name = product_property.value
            end
          end
        end
      end


      #------------------------------------------------------------------------------------------
      # option number
      #------------------------------------------------------------------------------------------
      option_number = ''
      item.product_customizations.each do |customization|
        next if customization.customized_product_options.all? { |cpo| cpo.value.empty? }
        if customization.product_customization_type.name.downcase == 'shirt-number'
          customization.customized_product_options.each do |option|
            next if option.value.empty?
            option_number = option.value
          end
        end
      end

      if option_number.empty?
        unless item.variant.product.product_properties.empty?
          for product_property in item.variant.product.product_properties
            if product_property.property.presentation.downcase == "shirt-number"
              option_number = product_property.value
            end
          end
        end
      end

      #------------------------------------------------------------------------------------------
      # option size
      #------------------------------------------------------------------------------------------
      option_size = ''
      item.ad_hoc_option_values.each do |pov|
        if pov.option_value.option_type.name.downcase == 'shirt-size'
          option_size = pov.option_value.presentation
        end
      end

      #------------------------------------------------------------------------------------------
      # option patch
      #------------------------------------------------------------------------------------------
      option_patch = ''
      item.ad_hoc_option_values.each do |pov|
        if pov.option_value.option_type.name.downcase == 'shirt-patch'
          option_patch = pov.option_value.presentation
        end
      end

      # -----------------------------------------------------------------------------------------
      # option season
      #------------------------------------------------------------------------------------------
      option_season = ''
      unless item.variant.product.product_properties.empty?
        for product_property in item.variant.product.product_properties
          if product_property.property.name.downcase == "shirt-season"
            option_season = product_property.value
          end
        end
      end

      #------------------------------------------------------------------------------------------
      # option team
      #------------------------------------------------------------------------------------------
      option_team = ''
      unless item.variant.product.product_properties.empty?
        for product_property in item.variant.product.product_properties
          if product_property.property.name.downcase == "shirt-team"
            option_team = product_property.value
          end
        end
      end

      #------------------------------------------------------------------------------------------
      # shirt_type
      #------------------------------------------------------------------------------------------
      option_type = ''
      unless item.variant.product.product_properties.empty?
        for product_property in item.variant.product.product_properties
          if product_property.property.name.downcase == "shirt-type"
            option_type = product_property.value
          end
        end
      end

      #------------------------------------------------------------------------------------------
      # shirt_sleeve
      #------------------------------------------------------------------------------------------
      option_sleeve = ''
      unless item.variant.product.product_properties.empty?
        for product_property in item.variant.product.product_properties
          if product_property.property.name.downcase == "shirt-sleeve"
            option_sleeve = product_property.value
          end
        end
      end


      sold.times { order.inventory_units.create({:shipment => shipment, :variant => variant, :state => 'sold'}, :without_protection => true) }

      back_order.times {
        order.inventory_units.create(
            {:shipment => shipment,
             :variant => variant, :state => 'backordered', :name => option_name.upcase, :number => option_number, :size => option_size,
             :patch => option_patch, :season => option_season, :team => option_team, :shirt_type => option_type, :sleeve => option_sleeve}, :without_protection => true
        ) }


    end

  end
end

