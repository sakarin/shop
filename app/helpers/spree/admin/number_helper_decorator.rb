module ActionView
  module Helpers
    module NumberHelper


      def number_to_currency(number, options = {})
        return nil if number.nil?

        options.symbolize_keys!


        #-----------------------------------------------------------------------------------
        #- hack base currency for admin view

        if @_controller.class.superclass.superclass == Spree::Admin::BaseController && !@order.nil?
          base_currency = @order.base_currency
          options[:locale] = "currency_#{ base_currency.to_s.upcase || I18n.default_locale }"
        elsif @_controller.class.superclass.superclass == Spree::BaseController && !@order.nil?
          base_currency = @order.base_currency
          options[:locale] = "currency_#{ base_currency.to_s.upcase || I18n.default_locale }"
        elsif !options[:base_locale].blank?
          options[:locale] = "currency_#{ options[:base_locale].to_s.upcase || I18n.default_locale }"
        else
          options[:locale] = "currency_#{ Spree::Currency.current.try(:char_code) || I18n.default_locale }"
        end

        #unless options[:base_locale].nil?
        #  options[:locale] = "currency_#{ options[:base_locale].to_s.upcase || I18n.default_locale }"
        #end
        #-----------------------------------------------------------------------------------

        defaults = I18n.translate('number.format', :locale => options[:locale], :default => {})
        currency = I18n.translate('number.currency.format', :locale => options[:locale], :default => {})


        defaults = DEFAULT_CURRENCY_VALUES.merge(defaults).merge!(currency)
        defaults[:negative_format] = "-" + options[:format] if options[:format]
        options = defaults.merge!(options)

        unit = options.delete(:unit)
        format = options.delete(:format)

        if number.to_f < 0
          format = options.delete(:negative_format)
          number = number.respond_to?("abs") ? number.abs : number.sub(/^-/, '')
        end

        begin
          value = number_with_precision(number, options.merge(:raise => true))
          format.gsub(/%n/, value).gsub(/%u/, unit).html_safe
        rescue InvalidNumberError => e
          if options[:raise]
            raise
          else
            formatted_number = format.gsub(/%n/, e.number).gsub(/%u/, unit)
            e.number.to_s.html_safe? ? formatted_number.html_safe : formatted_number
          end
        end

      end


    end
  end
end


