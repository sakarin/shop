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

    def create_adjustment(label, target, calculable, mandatory=false)
      amount = compute_amount(calculable)
      return if amount == 0 && !mandatory
      target.adjustments.create({ :amount => amount,
                                  :source => calculable,
                                  :originator => self,
                                  :label => label,
                                  :mandatory => mandatory}, :without_protection => true)
    end







  end
end