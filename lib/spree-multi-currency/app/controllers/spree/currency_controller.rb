module Spree
  class CurrencyController < Spree::BaseController

    def set
      if @currency = Currency.find_by_char_code(params[:id].to_s.upcase)

        if @order = current_order
          @order.line_items.destroy_all
        end

        session[:currency_id] = params[:id].to_s.upcase.to_sym
        Currency.current!(@currency)
        flash.notice = t(:currency_changed) + " to  #{session[:currency_id]}"
      else
        flash[:error] = t(:currency_not_found)
      end

      redirect_back_or_default(root_path)
    end
  end


end
