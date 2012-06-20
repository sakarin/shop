module Spree
  AdHocOptionType.class_eval do
    extend MultiCurrency
    multi_currency :price_modifier_type


  end

end
