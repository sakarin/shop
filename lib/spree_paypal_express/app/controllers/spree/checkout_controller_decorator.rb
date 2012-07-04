module Spree
  CheckoutController.class_eval do
    before_filter :redirect_to_paypal_express_form_if_needed, :only => [:update]

    def paypal_checkout
      load_order
      opts = all_opts(@order, params[:payment_method_id], 'checkout')
      opts.merge!(address_options(@order))
      @gateway = paypal_gateway

      if Spree::Config[:auto_capture]
        @ppx_response = @gateway.setup_purchase(opts[:money], opts)
      else
        @ppx_response = @gateway.setup_authorization(opts[:money], opts)
      end

      unless @ppx_response.success?
        gateway_error(@ppx_response)
        redirect_to edit_order_url(@order)
        return
      end

      redirect_to(@gateway.redirect_url_for(response.token, :review => payment_method.preferred_review))
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to :back
    end

    def paypal_payment
      load_order
      opts = all_opts(@order,params[:payment_method_id], 'payment')
      opts.merge!(address_options(@order))
      @gateway = paypal_gateway

      if Spree::Config[:auto_capture]
        @ppx_response = @gateway.setup_purchase(opts[:money], opts)
      else
        @ppx_response = @gateway.setup_authorization(opts[:money], opts)
      end

      unless @ppx_response.success?
        gateway_error(@ppx_response)
        redirect_to edit_order_checkout_url(@order, :state => "payment")
        return
      end

      redirect_to(@gateway.redirect_url_for(@ppx_response.token, :review => payment_method.preferred_review))
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to :back
    end

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
                                                  :phone      => @ppx_details.params["phone"] || "(not given)"

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

      else
        gateway_error(@ppx_details)

        #Failed trying to get payment details from PPX
        redirect_to edit_order_checkout_url(@order, :state => "payment")
      end
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to edit_order_url(@order)
    end

    def paypal_finish
      load_order

      opts = { :token => params[:token], :payer_id => params[:PayerID] }.merge all_opts(@order, params[:payment_method_id], 'payment' )
      gateway = paypal_gateway

      method = Spree::Config[:auto_capture] ? :purchase : :authorize
      ppx_auth_response = gateway.send(method, (@order.total*100).to_i, opts)

      paypal_account = Spree::PaypalAccount.find_by_payer_id(params[:PayerID])

      payment = @order.payments.create(
          :amount => ppx_auth_response.params["gross_amount"].to_f,
          :source => paypal_account,
          :source_type => 'Spree::PaypalAccount',
          :payment_method_id => params[:payment_method_id],
          :response_code => ppx_auth_response.params["ack"],
          :avs_response => ppx_auth_response.avs_result["code"])

      payment.started_processing!

      record_log payment, ppx_auth_response

      if ppx_auth_response.success?
        #confirm status
        case ppx_auth_response.params["payment_status"]
          when "Completed"
            payment.complete!
          when "Pending"
            payment.pend!
          else
            payment.pend!
            Rails.logger.error "Unexpected response from PayPal Express"
            Rails.logger.error ppx_auth_response.to_yaml
        end

        @order.update_attribute(:state, "complete")
        state_callback(:after) # So that after_complete is called, setting session[:order_id] to nil
        @order.finalize!
        flash[:notice] = I18n.t(:order_processed_successfully)
        redirect_to completion_route

      else
        payment.failure!
        order_params = {}
        gateway_error(ppx_auth_response)

        #Failed trying to complete pending payment!
        redirect_to edit_order_checkout_url(@order, :state => "payment")
      end
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to edit_order_url(@order)
    end

    private

    def asset_url(_path)
      URI::HTTP.build(:path => ActionController::Base.helpers.asset_path(_path), :host => Spree::Config[:site_url]).to_s
    end

    def record_log(payment, response)
      payment.log_entries.create(:details => response.to_yaml)
    end

    def redirect_to_paypal_express_form_if_needed
      return unless (params[:state] == "payment")
      return unless params[:order][:payments_attributes]

      if params[:order][:coupon_code]
        @order.update_attributes(object_params)
        if @order.coupon_code.present?
          fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
        end
      end

      load_order
      payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])

      if payment_method.kind_of?(Spree::BillingIntegration::PaypalExpress) || payment_method.kind_of?(Spree::BillingIntegration::PaypalExpressUk)
        redirect_to paypal_payment_order_checkout_url(@order, :payment_method_id => payment_method)
      end
    end

    def fixed_opts
      if Spree::PaypalExpress::Config[:paypal_express_local_confirm].nil?
        user_action = "continue"
      else
        user_action = Spree::PaypalExpress::Config[:paypal_express_local_confirm] == "t" ? "continue" : "commit"
      end

      #asset_url doesn't like Spree::Config[:logo] being an absolute url
      #if statement didn't work within hash
      if URI.parse(Spree::Config[:logo]).absolute?
        chosen_image = Spree::Config[:logo]
      else
        chosen_image = asset_url(Spree::Config[:logo])
      end


      { :description             => "Goods from #{Spree::Config[:site_name]}", # site details...
        #:page_style             => "foobar", # merchant account can set named config
        :background_color        => "ffffff",  # must be hex only, six chars
        :header_background_color => "ffffff",
        :header_border_color     => "ffffff",
        :header_image		 => chosen_image,
        :allow_note              => true,
        :locale                  => user_locale,
        :req_confirm_shipping    => false,   # for security, might make an option later
        :user_action             => user_action

        # WARNING -- don't use :ship_discount, :insurance_offered, :insurance since
        # they've not been tested and may trigger some paypal bugs, eg not showing order
        # see http://www.pdncommunity.com/t5/PayPal-Developer-Blog/Displaying-Order-Details-in-Express-Checkout/bc-p/92902#C851
      }
    end

    def user_locale
      I18n.locale.to_s
    end

    # hook to override paypal site options
    def paypal_site_opts
      {:currency => payment_method.preferred_currency, :allow_guest_checkout => payment_method.preferred_allow_guest_checkout }
    end

    def order_opts(order, payment_method, stage)
      items = order.line_items.map do |item|
        price = (item.price * 100).to_i # convert for gateway
        { :name        => item.variant.product.name,
          :description => (item.variant.product.description[0..120] if item.variant.product.description),
          :sku         => item.variant.sku,
          :quantity    => item.quantity,
          :amount      => price,
          :weight      => item.variant.weight,
          :height      => item.variant.height,
          :width       => item.variant.width,
          :depth       => item.variant.weight }
      end

      credits = order.adjustments.eligible.map do |credit|
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

      opts = { :return_url        => paypal_confirm_order_checkout_url(order, :payment_method_id => payment_method),
               :cancel_return_url => edit_order_checkout_url(order, :state => :payment),
               :order_id          => order.number,
               :custom            => order.number,
               :items             => items,
               :subtotal          => ((order.item_total * 100) + credits_total).to_i,
               :tax               => (order.tax_total*100).to_i,
               :shipping          => (order.ship_total*100).to_i,
               :money             => (order.total * 100 ).to_i }

      if stage == "checkout"
        opts[:handling] = 0

        opts[:callback_url] = spree_root_url + "paypal_express_callbacks/#{order.number}"
        opts[:callback_timeout] = 3
      elsif stage == "payment"
        #hack to add float rounding difference in as handling fee - prevents PayPal from rejecting orders
        #because the integer totals are different from the float based total. This is temporary and will be
        #removed once Spree's currency values are persisted as integers (normally only 1c)
        opts[:handling] =  (order.total*100).to_i - opts.slice(:subtotal, :tax, :shipping).values.sum
      end

      opts
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

    def all_opts(order, payment_method, stage=nil)
      opts = fixed_opts.merge(order_opts(order, payment_method, stage)).merge(paypal_site_opts)

      if stage == "payment"
        opts.merge! flat_rate_shipping_and_handling_options(order, stage)
      end

      # suggest current user's email or any email stored in the order
      opts[:email] = current_user ? current_user.email : order.email

      opts
    end

    # hook to allow applications to load in their own shipping and handling costs
    def flat_rate_shipping_and_handling_options(order, stage)
      # max_fallback = 0.0
      # shipping_options = ShippingMethod.all.map do |shipping_method|
      #       max_fallback = shipping_method.fallback_amount if shipping_method.fallback_amount > max_fallback
      #           { :name       => "#{shipping_method.id}",
      #             :label       => "#{shipping_method.name} - #{shipping_method.zone.name}",
      #             :amount      => (shipping_method.fallback_amount*100) + 1,
      #             :default     => shipping_method.is_default }
      #         end
      #
      #
      # default_shipping_method = ShippingMethod.find(:first, :conditions => {:is_default => true})
      #
      # opts = { :shipping_options  => shipping_options,
      #          :max_amount  => (order.total + max_fallback)*100
      #        }
      #
      # opts[:shipping] = (default_shipping_method.nil? ? 0 : default_shipping_method.fallback_amount) if stage == "checkout"
      #
      # opts
      {}
    end

    def gateway_error(response)
      if response.is_a? ActiveMerchant::Billing::Response
        text = response.params['message'] ||
            response.params['response_reason_text'] ||
            response.message
      else
        text = response.to_s
      end

      msg = "#{I18n.t('gateway_error')}: #{text}"
      logger.error(msg)
      flash[:error] = msg
    end

    # create the gateway from the supplied options
    def payment_method
      @payment_method ||= Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def paypal_gateway
      payment_method.provider
    end

  end
end
