module Spree
  Admin::OrdersController.class_eval do

    def index
      params[:q] ||= {}
      params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
      @show_only_completed = params[:q][:completed_at_not_null].present?
      #params[:q][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'


      if !params[:q][:created_at_gt].blank?
        params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
      end

      if !params[:q][:created_at_lt].blank?
        params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
      end

      if @show_only_completed
        params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
        params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
      end
      #params[:q][:meta_sort] ||= 'spree_payments.updated_at DESC'

      @search = Order.search(params[:q])
      @orders = @search.result.includes([:user, :shipments, :payments]).order('spree_payments.updated_at DESC').page(params[:page]).per(Spree::Config[:orders_per_page])

      respond_with(@orders)
    end


    def show
      @currency = Currency.find_by_char_code(@order.base_currency)
      Currency.current!(@currency)
      respond_with(@order)
    end

  end


end