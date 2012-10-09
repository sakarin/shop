module Spree
  CheckoutController.class_eval do

    before_filter :paypal_account , :only => [:paypal_payment, :order_opts]


    #---------------------------------------------------------------------------
    #- Check Store Before Send Data To Paypal
    #---------------------------------------------------------------------------
    #- send fake domain to paypal
    def paypal_account

      @preferences = Spree::Preference.find_by_key("spree/billing_integration/paypal_express/fake_domain/#{params[:payment_method_id]}")


      if Rails.env == "production"
        params[:host_with_port] = @preferences.value
      else
        params[:host_with_port] = @preferences.value + ":" + request.port.to_s

      end
    end

    #---------------------------------------------------------------------------
    #- Edit URL for Paypal Confirm
    #---------------------------------------------------------------------------
    def fixed_opts
      if Spree::PaypalExpress::Config[:paypal_express_local_confirm].nil?
        user_action = "continue"
      else
        user_action = Spree::PaypalExpress::Config[:paypal_express_local_confirm] == "t" ? "continue" : "commit"
      end

      { :description             => "Goods from #{Spree::Config[:site_name]}", # site details...

        #:page_style             => "foobar", # merchant account can set named config
        :header_image            => "https://#{Spree::Config[:site_url]}#{Spree::Config[:logo]}",
        :background_color        => "ffffff",  # must be hex only, six chars
        :header_background_color => "ffffff",
        :header_border_color     => "ffffff",
        :allow_note              => true,
        :locale                  => "#{request.protocol}#{params[:host_with_port]}" ,
        :req_confirm_shipping    => false,   # for security, might make an option later
        :user_action             => user_action

        # WARNING -- don't use :ship_discount, :insurance_offered, :insurance since
        # they've not been tested and may trigger some paypal bugs, eg not showing order
        # see http://www.pdncommunity.com/t5/PayPal-Developer-Blog/Displaying-Order-Details-in-Express-Checkout/bc-p/92902#C851
      }
    end

    #---------------------------------------------------------------------------
    #- Edit URL for Paypal Confirm
    #---------------------------------------------------------------------------
    def order_opts(order, payment_method, stage)
      items = order.line_items.map do |item|
        price = (item.price * 100).to_i # convert for gateway
        { :name        => "#{order.invoice}",
          :description => (item.variant.product.description[0..120] if item.variant.product.description),
          :sku         => item.variant.sku,
          :quantity    => item.quantity,
          :amount      => price,
          :weight      => item.variant.weight,
          :height      => item.variant.height,
          :width       => item.variant.width,
          :depth       => item.variant.weight }
      end

      credits = order.adjustments.map do |credit|
        if credit.amount < 0.00
          { :name        => credit.label,
            :description => credit.label,
            :sku         => credit.id,
            :quantity    => 1,
            :amount      => (credit.amount*100).to_i }
        end
      end

      credits_total = 0
      credits.compact!
      if credits.present?
        items.concat credits
        credits_total = credits.map {|i| i[:amount] * i[:quantity] }.sum
      end

      if params[:host_with_port].nil?
        params[:host_with_port] = request.host_with_port
      end

      opts = { :return_url        => request.protocol + params[:host_with_port] + "/confirm/" + "orders/#{order.invoice}/checkout/paypal_confirm?payment_method_id=#{payment_method}",
               :cancel_return_url => request.protocol + params[:host_with_port],
               :order_id          => order.invoice,
               :custom            => order.invoice,
               :items             => items,
               :subtotal          => ((order.item_total * 100) + credits_total).to_i,
               :tax               => ((order.adjustments.map { |a| a.amount if ( a.source_type == 'Order' && a.label == 'Tax') }.compact.sum) * 100 ).to_i,
               :shipping          => ((order.adjustments.map { |a| a.amount if a.source_type == 'Shipment' }.compact.sum) * 100 ).to_i,
               :money             => (order.total * 100 ).to_i }

      # add correct tax amount by subtracting subtotal and shipping otherwise tax = 0 -> need to check adjustments.map
      #opts[:tax] = (order.total*100).to_i - opts.slice(:subtotal, :shipping).values.sum

      if stage == "checkout"
        opts[:handling] = 0

        opts[:callback_url] = spree_root_url + "paypal_express_callbacks/#{order.invoice}"
        opts[:callback_timeout] = 3
      elsif stage == "payment"
        #hack to add float rounding difference in as handling fee - prevents PayPal from rejecting orders
        #because the integer totals are different from the float based total. This is temporary and will be
        #removed once Spree's currency values are persisted as integers (normally only 1c)
        opts[:handling] =  (order.total*100).to_i - opts.slice(:subtotal, :tax, :shipping).values.sum
      end

      opts
    end

    # hook to override paypal site options
    def paypal_site_opts
      {:currency => session[:currency_id].present? ? session[:currency_id].to_s : "GBP"}
    end


    #---------------------------------------------------------------------------
    #- Update Address From Paypal Data
    #---------------------------------------------------------------------------
    def paypal_confirm
      load_order

      opts = { :token => params[:token], :payer_id => params[:PayerID] }.merge all_opts(@order, params[:payment_method_id],  'payment')
      gateway = paypal_gateway

      @ppx_details = gateway.details_for params[:token]

      if @ppx_details.success?
        # now save the updated order info

        Spree::PaypalAccount.create(:email => @ppx_details.params["payer"],
                                    :payer_id => @ppx_details.params["payer_id"],
                                    :payer_country => @ppx_details.params["payer_country"],
                                    :payer_status => @ppx_details.params["payer_status"])

        @order.special_instructions = @ppx_details.params["note"]

        #---------------------------------------------------------------------------
        #- Update Base Currency
        #---------------------------------------------------------------------------
        @order.base_currency = @ppx_details.params["order_total_currency_id"]
        #---------------------------------------------------------------------------

        if payment_method.preferred_no_shipping
          ship_address = @ppx_details.address
          order_ship_address = Spree::Address.new :firstname  => @ppx_details.params["first_name"],
                                                  :lastname   => @ppx_details.params["last_name"],
                                                  :address1   => ship_address["address1"],
                                                  :address2   => ship_address["address2"],
                                                  :city       => ship_address["city"],
                                                  :country    => Spree::Country.find_by_iso(ship_address["country"]),
                                                  :zipcode    => ship_address["zip"],
                                                  # phone is currently blanked in AM's PPX response lib
                                                  :phone      => @ppx_details.params["phone"] || ""

          if (state = Spree::State.find_by_abbr(ship_address["state"]))
            order_ship_address.state = state
          else
            order_ship_address.state_name = ship_address["state"]
          end
          order_ship_address.save!

          @order.ship_address = order_ship_address
          @order.bill_address ||= order_ship_address
        end



        @order.save

        if payment_method.preferred_review
          render 'spree/shared/paypal_express_confirm'
        else
          paypal_finish
        end

        #Hack shipment not update
        @order.shipment.update!(@order)

      else
        gateway_error(@ppx_details)

        #Failed trying to get payment details from PPX
        redirect_to edit_order_checkout_url(@order, :state => "payment")
      end
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to edit_order_url(@order)
    end



    def address_options(order)
      if payment_method.preferred_no_shipping
        { :no_shipping => false }
      else
        {
            :no_shipping => false,
            :address_override => true,
            :address => {
                :name       => "#{order.ship_address.firstname} #{order.ship_address.lastname}",
                :address1   => order.ship_address.address1,
                :address2   => order.ship_address.address2,
                :city       => order.ship_address.city,
                :state      => order.ship_address.state.nil? ? order.ship_address.state_name.to_s : order.ship_address.state.abbr,
                :country    => order.ship_address.country.iso,
                :zip        => order.ship_address.zipcode,
                :phone      => order.ship_address.phone
            }
        }
      end
    end

  end
end
