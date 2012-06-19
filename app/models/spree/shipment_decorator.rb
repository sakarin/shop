module Spree
  Shipment.class_eval do




    private
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


  end
end