module Spree
  Admin::ShipmentsController.class_eval do

    before_filter :load_shipment, :only => [:destroy, :edit, :update, :fire, :home, :download]
    before_filter :load_shipping_methods, :except => [:country_changed, :index, :home, :download]

    def home
      params[:q] ||= {}
      params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
      @show_only_completed = params[:q][:completed_at_not_null].present?
      params[:q][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'



      if @show_only_completed
        params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
        params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
      end

      @search = Order.where("shipment_state != 'shipped'").search(params[:q])
      @orders = @search.result.includes([:user, :shipments, :payments]).page(params[:page]).per(Spree::Config[:orders_per_page])

      respond_with(@orders)

    end

    def download
      @files = ShipmentFile.order('created_at DESC').page(params[:page]).per(Spree::Config[:orders_per_page])
    end

  end
end
