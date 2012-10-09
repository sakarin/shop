module Spree
  class PaypalConfirmController < Spree::BaseController

    skip_before_filter :verify_authenticity_token

    def paypal
      path = "#{@_env['PATH_INFO']}".gsub("confirm/", "")

      # Hack find by invoice
      @order = Order.find_by_invoice(params[:order_id])

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

    def generate_last_purchase_order_id
        PurchaseItem.order("id DESC").each do |item|
          @purchase_item = Spree::PurchaseItem.find_by_sql("SELECT * FROM spree_purchase_items WHERE inventory_unit_id = #{item.inventory_unit_id} AND id < #{item.id}  ORDER BY id DESC" ).first
          unless @purchase_item.nil?
            @item = PurchaseItem.find(item.id)
            @item.update_attributes(:last_purchase_order_id => @purchase_item.purchase_order_id )
            @item.reload
          end


        end

    end

    def paypal_invoice
      orders = Order.complete

      orders.each do |order|
        order.shipments.each do |shipment|
          shipment.update!(order)
        end
        order.update!
      end




      #p = PaypalNVP.new(true) # true mean "use sandbox"
      #                        # Or you can specify paramaters directly
      #                        # p = PaypalNVP.new(true, { :user => "o.bonn_1237393081_biz_api1.solisoft.net", :pass => "1237393093", :cert => "AU2Yv5COwWPCfeYLv34Z766F-gfNAzX6LaQE6VZkHMRq35Gmite-bMXu", :url => "https://api-3t.sandbox.paypal.com/nvp" })
      #data = {
      #    #:version => "50.0", # Default is 50.0 as well... but now you can specify it
      #    #:method => "MyPaypalMethod",
      #    #:amt => "55"
      #    # other params needed
      #    :mc_gross => "37.12",
      #    :protection_eligibility => "Eligible",
      #    :address_status => "confirmed",
      #    :payer_id => "ABF644D44GSPJ",
      #    :address_street => "5656 South Market Street",
      #    :payment_date => "15:57:39 Sep 12, 2011 PDT",
      #    :payment_status => "Completed" ,
      #    :invoice_id => "INV2-VMYW-LQKA-QBGC-6YDE" ,
      #    :charset => "windows-1252",
      #    :address_zip => "95131",
      #    :first_name => "Nick",
      #    :mc_fee => "1.38",
      #    :address_country_code => "US",
      #    :address_name => "Selling Fruits",
      #    :notify_version => "3.4",
      #    :payer_status => "verified" ,
      #    :business => "jbui-us-business1@paypal.com",
      #    :address_country => "United States" ,
      #    :address_city => "San Jose" ,
      #    :verify_sign => "AFcWxV21C7fd0v3bYYYRCpSSRl31A23x28hwIQCThw2nNi2s8MlV2o10" ,
      #    :payer_email => "jbui-us-personal1@paypal.com",
      #    :txn_id => "68H067535A2789915" ,
      #    :payment_type => "instant" ,
      #    :last_name => "Ronald" ,
      #    :address_state => "CA" ,
      #    :receiver_email => "jbui-us-business1@paypal.com" ,
      #    :payment_fee => "1.38" ,
      #    :receiver_id => "9N3VVZS28ELHL" ,
      #    :txn_type => "invoice_payment" ,
      #    :mc_currency => "USD" ,
      #    :residence_country => "US" ,
      #    :transaction_subject => "Send the Reminder Soon." ,
      #    :invoice_number => "0151" ,
      #    :payment_gross => "37.12" ,
      #    :ipn_track_id => "ogo4fwr-n.J7dGNgDiJzqg"
      #
      #}
      #result = p.call_paypal(data) # will return a hash
      #puts result["ACK"] # Success
      #
      #render nil
    end

  end
end