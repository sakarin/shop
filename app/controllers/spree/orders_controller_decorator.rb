module Spree
  OrdersController.class_eval do

    def show
      @order = Order.find_by_number!(params[:id])

      @currency = Currency.find_by_char_code(@order.base_currency)
      Currency.current!(@currency)

      respond_with(@order)
    end

  end
end
