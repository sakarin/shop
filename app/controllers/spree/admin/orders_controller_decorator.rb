module Spree
  Admin::OrdersController.class_eval do


    def show
      @currency = Currency.find_by_char_code(@order.base_currency)
      Currency.current!(@currency)
      respond_with(@order)
    end

  end


end