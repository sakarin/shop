module Spree
  module Admin
    class PurchaseOrdersController < Spree::Admin::BaseController

      before_filter :load_suppliers, :only => [:new, :edit, :update, :fire]
      before_filter :load_purchase_order, :except => [:download]

      respond_to :html

      def index
        params[:q] ||= {}
        if !params[:q][:created_at_greater_than].blank?
          params[:q][:created_at_greater_than] = Time.zone.parse(params[:q][:created_at_greater_than]).beginning_of_day rescue ""
        end
        if !params[:q][:created_at_less_than].blank?
          params[:q][:created_at_less_than] = Time.zone.parse(params[:q][:created_at_less_than]).end_of_day rescue ""
        end
        @search = PurchaseOrder.search(params[:q])
        @purchase_orders = @search.result.includes([:supplier]).page(params[:page]).per(Spree::Config[:orders_per_page])

        respond_with(@purchase_orders)
      end

      def new
        load_inventory_units
        @purchase_order = PurchaseOrder.new
        respond_with(@purchase_order)
      end

      def create
        @purchase_order = PurchaseOrder.new(params[:purchase_order])
        if @purchase_order.save
          # get inventory from new
          (params[:units] || []).each do |unit|
            @unit = InventoryUnit.find(unit[0])
            max = (params[:unit_quantity][unit[0]]).to_i
            # find inventory unit with max quantity
            if @unit.po_version == 0
              @units = InventoryUnit.where(:state => @unit.state, :variant_id => @unit.variant_id, :name => @unit.name,
                                           :number => @unit.number, :size => @unit.size, :patch => @unit.patch,
                                           :season => @unit.season, :team => @unit.team, :shirt_type => @unit.shirt_type,
                                           :sleeve => @unit.sleeve, :po_version => 0).limit(max)

              (@units || []).each do |inventory_unit|
                logger.debug "-----------------------------------------------------------------------------------------"
                logger.debug "purchase item : #{inventory_unit.id}"

                PurchaseItem.create(:purchase_order_id => @purchase_order.id, :inventory_unit_id => inventory_unit.id)
              end
            else
              #"SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              #INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              #INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              #WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version > 0
              #GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve, spree_purchase_items.purchase_order_id
              #ORDER BY team ASC, name ASC, id ASC"

              #@units = InventoryUnit.find_by_sql(
              #    "SELECT spree_inventory_units.* FROM spree_inventory_units
              #INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              #INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              #WHERE spree_inventory_units.state = '#{@unit.state}' AND spree_inventory_units.variant_id = #{@unit.variant_id}  AND spree_inventory_units.name = '#{@unit.name}'
              #  AND spree_inventory_units.number = '#{@unit.number}' AND spree_inventory_units.size = '#{@unit.size}' AND spree_inventory_units.patch = '#{@unit.patch}'
              #  AND spree_inventory_units.season = '#{@unit.season}' AND spree_inventory_units.team = '#{@unit.team}' AND spree_inventory_units.shirt_type = '#{@unit.shirt_type}'
              #  AND spree_inventory_units.sleeve = '#{@unit.sleeve}' AND spree_inventory_units.po_version > 0
              #GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve, spree_purchase_items.purchase_order_id
              #ORDER BY team ASC, name ASC, id ASC LIMIT #{max}")

              @units = InventoryUnit.where("state = ? AND variant_id = ? AND name = ? AND number = ? AND size = ? AND patch = ? AND season = ? AND team = ? AND shirt_type = ? AND sleeve = ? AND po_version >0 AND id >= ?",
                                           @unit.state, @unit.variant_id, @unit.name, @unit.number, @unit.size, @unit.patch, @unit.season, @unit.team, @unit.shirt_type, @unit.sleeve, @unit.id).limit(max)

              (@units || []).each do |inventory_unit|
                inventory_unit
                PurchaseItem.create(:purchase_order_id => @purchase_order.id, :inventory_unit_id => inventory_unit.id)
              end
            end

          end

          flash[:notice] = flash_message_for(@purchase_order, :successfully_created)
          respond_with(@purchase_order) do |format|
            format.html { redirect_to edit_admin_purchase_order_path(@purchase_order) }
          end
        else
          respond_with(@purchase_order) { |format| format.html { render :action => 'new' } }
        end
      end

      def edit
        #@items = @purchase_order.inventory_units
        #load_purchase_with_items

        load_purchasing_order
        respond_with(@purchase_order)
      end

      def update
        if @purchase_order.update_attribute(:supplier_id, params[:purchase_order][:supplier_id])

          inventory_unit_ids =@purchase_order.inventory_unit_ids

          # remove inventory_unit all in purchase_order
          (@purchase_order.purchase_items || []).each do |unit|
            unit.destroy
          end

          # create purchase_items
          (params[:units] || []).each do |unit|
            @unit = InventoryUnit.find(unit[0])
            max = (params[:unit_quantity][unit[0]]).to_i
            # find inventory unit with max quantity
            @units = InventoryUnit.where(:state => @unit.state, :variant_id => @unit.variant_id, :name => @unit.name,
                                         :number => @unit.number, :size => @unit.size, :patch => @unit.patch,
                                         :season => @unit.season, :team => @unit.team, :shirt_type => @unit.shirt_type,
                                         :sleeve => @unit.sleeve, :po_version => @unit.po_version).limit(max)

            (@units || []).each do |inventory_unit|
              PurchaseItem.create(:purchase_order_id => @purchase_order.id, :inventory_unit_id => inventory_unit.id)
            end
          end

          # update old inventory_units
          (inventory_unit_ids || []).each do |item|
            unit = InventoryUnit.find(item)
            determine_unit_po_version(unit)
          end


          flash[:notice] = flash_message_for(@purchase_order, :successfully_updated)
          respond_with(@purchase_order) do |format|
            format.html { redirect_to admin_purchase_orders_path }
          end
        else
          respond_with(@purchase_order) { |format| format.html { render :action => 'edit' } }
        end
      end


      def purchase_by_order
        @order = Order.find_by_number(params[:order_id])
        @inventory_units = @order.inventory_units

        render "purchases"
      end

      def destroy

        inventory_unit_ids = @purchase_order.inventory_unit_ids

        @purchase_order.destroy

        # update old inventory_units
        (inventory_unit_ids || []).each do |item|
          unit = InventoryUnit.find(item)
          determine_unit_po_version(unit)
        end


        respond_with(@purchase_order) do |format|
          format.js { render_js_for_destroy }

        end

      end

      def download
        @files = PurchaseOrderFile.order('created_at DESC').page(params[:page]).per(Spree::Config[:orders_per_page])
      end

      def show
        purchase_file = PurchaseOrderFile.find_by_name(@purchase_order.number)
        if purchase_file.blank?
          PurchaseOrderFile.create(:name => @purchase_order.number)
        end

        load_purchasing_order_file_generate_file

        if Rails.env == "production"
        end

        ToXls::ArrayWriter.new(@backorder_inventory_units, :name => 'purchase_order',
                               :columns => [:season, :team, :shirt_type, :name, :number, :size, :sleeve, :patch, :quantity],
                               :headers => ['Season', 'Team', 'Type', 'Number', 'Number', 'Size', 'Sleeve', 'Patch', 'Quantity']).write_io("#{Rails.root}/public/files/purchases/#{@purchase_order.number}.xls")

        html = render_to_string(:action => "show.html.erb", :layout => 'report')

        kit = PDFKit.new(html)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/print.css"

        send_data(kit.to_pdf, :filename => "#{@purchase_order.number}.pdf", :type => 'application/pdf')
        kit.to_file("#{Rails.root}/public/files/purchases/#{@purchase_order.number}.pdf")


        @purchase_order.purchased

        (@purchase_order.inventory_units || []).each do |unit|
          determine_unit_po_version(unit)
          unit.fill_backorder
        end
      end


      protected

      def determine_unit_po_version(unit)
        unit.update_attributes(:po_version => unit.purchase_items.size() || 0)
        if unit.po_version.size() == 0
          unit.pending
        end
      end

      def load_purchase_order
        @purchase_order ||= PurchaseOrder.find_by_number(params[:id]) if params[:id]
        @purchase_order
      end

      def load_inventory_units
        backorder_inventory_units
        pending_inventory_units
      end

      def load_suppliers
        @suppliers = Supplier.all
      end

      def load_purchasing_order_file_generate_file
        @backorder_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_purchase_orders.id = #{@purchase_order.id}
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve
             ORDER BY team ASC, name ASC, id ASC")

      end


      # Load data for new
      def backorder_inventory_units
        @backorder_inventory_units ||= Spree::InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_orders ON spree_inventory_units.order_id = spree_orders.id
              WHERE spree_orders.payment_state LIKE 'paid' AND spree_inventory_units.state LIKE 'backordered' AND spree_inventory_units.po_version = 0
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve
              ORDER BY team ASC, name ASC, id ASC")

      end

      def pending_inventory_units
        @pending_inventory_units ||= Spree::InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_orders ON spree_inventory_units.order_id = spree_orders.id
              INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_orders.payment_state LIKE 'paid' AND spree_inventory_units.state LIKE 'backordered' AND spree_inventory_units.po_version > 0
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve, spree_purchase_items.purchase_order_id
              ORDER BY team ASC, name ASC ,id ASC")
      end


      # Load data for edit
      def load_purchasing_order
        @backorder_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version = 0
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve
              ORDER BY team ASC, name ASC, id ASC")

        @pending_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version > 0
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve, spree_purchase_items.purchase_order_id
              ORDER BY team ASC, name ASC, id ASC")

      end

      def load_purchase_with_items
        str_sql =""
        @items.each do |item|
          unless @items.last == item
            str_sql +=  "#{item.id}, "
          else
            str_sql += "#{item.id}"
          end
        end

       @pu = PurchaseOrder.find_by_sql(
              "SELECT spree_purchase_orders.id, COUNT( spree_purchase_orders.id ) AS quantity
              FROM spree_purchase_orders
              INNER JOIN spree_purchase_items ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_purchase_items.inventory_unit_id
              IN ( #{str_sql} )
              GROUP BY spree_purchase_orders.id")


      end


    end
  end

end
