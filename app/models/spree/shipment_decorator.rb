module Spree
  Shipment.class_eval do

    scope :shipped, where(:state => 'shipped')
    scope :ready, where(:state => 'ready')
    scope :pending, where(:state => 'pending')
    scope :packet, where(:state => 'packet')

    # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'pending', :use_transactions => false do

      event :pend do
        transition :from => 'ready', :to => 'pending'
      end
      event :ready do
        transition :from => 'pending', :to => 'ready'
      end
      event :pack do
        transition :from => 'ready', :to => 'packet'
      end
      event :ship do
        transition :from => 'packet', :to => 'shipped'
      end

      after_transition :to => 'shipped', :do => :after_ship
    end





    def generate_shipment_number
      order = Order.find(self.order_id)
      number = order.number.delete("R")
      count = Shipment.where("number LIKE '%H#{number}%'").count
      if count == 0
        self.number = "H" + "#{number}-1"
      else
        self.number = "H" + "#{number}-#{count + 1}"
      end
    end

    def ensure_correct_adjustment
      if adjustment
        adjustment.originator = shipping_method
        adjustment.save
      else
        if self.order.shipments.size == 1
          shipping_method.create_adjustment(I18n.t(:shipping), order, self, true)
          reload #ensure adjustment is present on later saves
        end
      end
    end

    def determine_state(order)
      self.inventory_units.each do |unit|
        unit.backordered?

      end

      return 'pending' if self.inventory_units.any? { |unit| unit.backordered? }
      return 'pending' if self.inventory_units.any? { |unit| unit.refund? }
      return 'packet'  if state == 'packet'
      return 'shipped' if state == 'shipped'
      order.payment_state == 'balance_due' ? 'pending' : 'ready'
    end

    def after_ship
      inventory_units.each &:ship
      ShipmentMailer.shipped_email(self).deliver
    end

    def require_inventory
      #return false unless Spree::Config[:track_inventory_levels]
      #order.completed? && !order.canceled?
    end


  end
end