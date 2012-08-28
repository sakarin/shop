module Spree
  class PaypalConfirmController < Spree::BaseController

    skip_before_filter :verify_authenticity_token

    def paypal
      path = "#{@_env['PATH_INFO']}".gsub("confirm/", "")


      @order = Order.find_by_number(params[:order_id])

      @store = Store.find(@order.store_id)

      if Rails.env == "production"
        redirect_to "http://" + @store.domains + path + "?" + "#{@_env['QUERY_STRING']}"
      else
        #logger.debug "----------------------------------------------------------------------------"
        #logger.debug "@store.domains : #{@store.domains}"
        #logger.debug "request.host_with_port : #{request.host_with_port}"
        #logger.debug "request.port : #{request.port}"
        #logger.debug "----------------------------------------------------------------------------"

        redirect_to "http://" + @store.domains + ":"+ request.port.to_s + path + "?" + "#{@_env['QUERY_STRING']}"
      end

    end

  end
end