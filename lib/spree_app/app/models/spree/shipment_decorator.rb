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







  end
end