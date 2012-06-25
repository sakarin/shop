module Spree
  Admin::ShipmentsController.class_eval do

    before_filter :load_shipment, :only => [:destroy, :edit, :update, :fire, :home, :download]
    before_filter :load_shipping_methods, :except => [:country_changed, :index, :home, :download, :preview, :print]

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

    def preview
      @shipments = Shipment.ready
    end

    def print
      @shipments = Shipment.ready

      @shipment_file = ShipmentFile.create()



      html = render_to_string(:action => "print.html.erb" , :layout => 'report')
      kit = PDFKit.new(html)
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/print.css"

      send_data(kit.to_pdf, :filename => "#{@shipment_file.name}.pdf", :type => 'application/pdf')
      kit.to_file("#{Rails.root}/public/files/shipments/#{@shipment_file.name}.pdf")



      (@shipments || []).each do |shipment|
        inventory_units = InventoryUnit.where(:state => 'sold', :shipment_id => shipment.id)
        inventory_units.each &:pack!
      end

      @shipments.each &:pack!


    end

  end
end
