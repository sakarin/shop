module Spree
  AdHocOptionValue.class_eval do
    extend MultiCurrency
    multi_currency :price_modifier
  end
end
