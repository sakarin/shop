module Spree
  Admin::ProductsController.class_eval do
    before_filter :default_currency, :only => [:index, :edit]

    def default_currency
      @currency = Currency.find_by_char_code('GBP')
      Currency.current!(@currency)
    end


  end


end