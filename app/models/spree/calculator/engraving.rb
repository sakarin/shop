module Spree
  class Calculator::Engraving < Calculator

    preference :price_per_letter, :decimal
    attr_accessible :preferred_price_per_letter



    def self.description
      "One Time Constant Calculator"
    end

    def self.register
      super
      ProductCustomizationType.register_calculator(self)
    end

    def create_options
      # This calculator knows that it needs one CustomizableOption named number or name
      [
          CustomizableProductOption.create(:name => "inscription", :presentation => "Inscription")
      ]
    end

    def compute(product_customization, variant=nil)
      return 0 unless valid_configuration? product_customization

      opt_number = product_customization.customized_product_options.detect { |cpo| cpo.customizable_product_option.name == "number" } rescue ''
      opt_name = product_customization.customized_product_options.detect { |cpo| cpo.customizable_product_option.name == "name" } rescue ''

      if !opt_number.nil?
        return preferred_price_per_letter
      elsif !opt_name.nil?
        return preferred_price_per_letter
      else
        return 0
      end


    end

    def valid_configuration?(product_customization)
      true
    end
  end
end
