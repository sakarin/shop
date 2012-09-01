module Spree
  Admin::AdjustmentsController.class_eval do
    before_filter :base_currency, :only => [:index, :edit]

    private
    def base_currency
      @currency = Currency.find_by_char_code(@order.base_currency)
      Currency.current!(@currency)
    end

  end
end