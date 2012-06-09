module Spree
  class PaypalConfirmController < Spree::BaseController

    skip_before_filter :verify_authenticity_token

    def paypal
      path = "#{@_env['PATH_INFO']}".gsub("confirm/", "")

      #@order = Order.where("number = ?", "#{params[:order_id]}").first
      @order = Order.find_by_number(params[:order_id])
      #@store = Store.where("id = ?", @order.store_id).first
      @store = Store.find(@order.store_id)

      if Rails.env == "production"
        redirect_to "http://" + @store.domains + path + "?" + "#{@_env['QUERY_STRING']}"
      else
        logger.error "----------------------------------------------------------------------------"
        logger.error "@store.domains : #{@store.domains}"
        logger.error "request.host_with_port : #{request.host_with_port}"
        logger.error "request.port : #{request.port}"
        logger.error "----------------------------------------------------------------------------"

        redirect_to "http://" + @store.domains + ":3000" + path + "?" + "#{@_env['QUERY_STRING']}"
      end

    end

  end
end