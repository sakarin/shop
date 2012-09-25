module Spree
  module Admin
    class ReceiveProductsController < Spree::Admin::BaseController

      before_filter :load_purchase_order
      before_filter :load_receive_product, :only => [:edit, :update, :destroy]


      respond_to :html

      def index
        @receive_products = @purchase_order.receive_products
        respond_with(@receive_products)
      end

      def new
        load_receive_item
        #@receive_product = ReceiveProduct.new
      end

      def create
        build_receive_product

        if @receive_product.save
          (@receive_product.purchase_order.inventory_units || []).each do |inventory_unit|
            inventory_unit.pending
          end


          # get inventory from new
          (params[:units] || []).each do |unit|
            @unit = InventoryUnit.find(unit[0])
            max = (params[:unit_quantity][unit[0]]).to_i
            # find inventory unit with max quantity
            #@units = InventoryUnit.where(:state => @unit.state, :variant_id => @unit.variant_id, :name => @unit.name, :number => @unit.number, :size => @unit.size, :patch => @unit.patch, :season => @unit.season, :team => @unit.team, :shirt_type => @unit.shirt_type, :sleeve => @unit.sleeve).limit(max)
            @units = InventoryUnit.where("state = ? AND variant_id = ? AND name = ? AND number = ? AND size = ? AND patch = ? AND season = ? AND team = ? AND shirt_type = ? AND sleeve = ? AND order_id = ? AND id >= ?",
                                         @unit.state, @unit.variant_id, @unit.name, @unit.number, @unit.size, @unit.patch, @unit.season, @unit.team, @unit.shirt_type, @unit.sleeve, @unit.order_id, @unit.id).limit(max)


            (@units || []).each do |inventory_unit|
              ReceiveItem.create(:receive_product_id => @receive_product.id, :inventory_unit_id => inventory_unit.id)
              inventory_unit.sold
            end
          end

          flash[:notice] = flash_message_for(@receive_product, :successfully_created)
          respond_with(@receive_product) do |format|
            format.html { redirect_to edit_admin_purchase_order_receive_product_path(@purchase_order, @receive_product) }
          end
        else
          respond_with(@receive_product) { |format| format.html { render :action => 'new' } }
        end

      end

      def edit
        load_receive_item_by_receive_product
      end

      def update

        @purchase_order.received if params[:units].size() > 0

        (@receive_product.receive_items || []).each do |item|
          item.destroy
        end

        (params[:units] || []).each do |unit|

          @unit = InventoryUnit.find(unit[0])
          max = (params[:unit_quantity][unit[0]]).to_i
          # find inventory unit with max quantity
          #@units = InventoryUnit.where(:state => @unit.state, :variant_id => @unit.variant_id, :name => @unit.name, :number => @unit.number, :size => @unit.size, :patch => @unit.patch, :season => @unit.season, :team => @unit.team, :shirt_type => @unit.shirt_type, :sleeve => @unit.sleeve).limit(max)
          @units = InventoryUnit.where("state = ? AND variant_id = ? AND name = ? AND number = ? AND size = ? AND patch = ? AND season = ? AND team = ? AND shirt_type = ? AND sleeve = ? AND order_id = ? AND id >= ?",
                                       @unit.state, @unit.variant_id, @unit.name, @unit.number, @unit.size, @unit.patch, @unit.season, @unit.team, @unit.shirt_type, @unit.sleeve, @unit.order_id, @unit.id).limit(max)


          (@units || []).each do |inventory_unit|
            ReceiveItem.create(:receive_product_id => @receive_product.id, :inventory_unit_id => inventory_unit.id)
            inventory_unit.sold
          end

        end

        flash[:notice] = flash_message_for(@receive_product, :successfully_updated)
        respond_with(@receive_product) do |format|
          format.html { redirect_to edit_admin_purchase_order_receive_product_path(@purchase_order, @receive_product) }
        end

      end

      def destroy

        inventory_unit_ids = @receive_product.inventory_unit_ids

        @receive_product.purchase_order.purchased

        @receive_product.destroy

        # update old inventory_units
        (inventory_unit_ids || []).each do |item|
          unit = InventoryUnit.find(item)
          determine_unit_po_version(unit)
        end

        respond_with(@receive_product) { |format| format.js { render_js_for_destroy } }
      end

      def receive_orders
        @order = Order.find_by_number(params[:order_id])
        @inventory_units = @order.inventory_units
        render "receives"
      end


      private

      def determine_unit_po_version(unit)
        unit.update_attributes(:po_version => unit.purchase_items.size() || 0)
        if unit.po_version.size() == 0
          unit.pending
        else
          unit.fill_backorder
        end
      end

      def build_receive_product
        @receive_product = @purchase_order.receive_products.build
      end

      def load_purchase_order
        @purchase_order = PurchaseOrder.find_by_number(params[:purchase_order_id]) if params[:purchase_order_id]
      end

      def load_receive_product
        @receive_product = ReceiveProduct.find_by_number(params[:id])
        @receive_product
      end

      #def load_receive_item
      #  @pending_inventory_units = InventoryUnit.find_by_sql(
      #      "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
      #        INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
      #        INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
      #        WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version > 0
      #              AND spree_inventory_units.state LIKE 'purchased'
      #        GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")
      #
      #  @backorder_inventory_units = InventoryUnit.find_by_sql(
      #      "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
      #        INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
      #        INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
      #        WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version = 0
      #              AND spree_inventory_units.state LIKE 'purchased'
      #        GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")
      #
      #end

      def load_receive_item
        @pending_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units . * , COUNT( spree_inventory_units.variant_id ) AS quantity FROM spree_inventory_units
            INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
            INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
            INNER JOIN spree_payments ON spree_payments.order_id = spree_inventory_units.order_id
            WHERE spree_purchase_orders.id = #{@purchase_order.id}
            AND spree_inventory_units.po_version > 0
            AND spree_inventory_units.state LIKE  'purchased'
            GROUP BY order_id, variant_id, name, number, size, patch, season, team, shirt_type, sleeve
            ORDER BY spree_payments.updated_at DESC")

        @backorder_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units . * , COUNT( spree_inventory_units.variant_id ) AS quantity FROM spree_inventory_units
            INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
            INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
            INNER JOIN spree_payments ON spree_payments.order_id = spree_inventory_units.order_id
            WHERE spree_purchase_orders.id = #{@purchase_order.id}
            AND spree_inventory_units.po_version = 0
            AND spree_inventory_units.state LIKE  'purchased'
            GROUP BY order_id, variant_id, name, number, size, patch, season, team, shirt_type, sleeve
            ORDER BY spree_payments.updated_at DESC")

      end


      #def load_receive_item_by_receive_product
      #  @pending_inventory_units = InventoryUnit.find_by_sql(
      #      "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
      #        INNER JOIN spree_receive_items ON spree_receive_items.inventory_unit_id = spree_inventory_units.id
      #        INNER JOIN spree_receive_products ON spree_receive_products.id = spree_receive_items.receive_product_id
      #        WHERE spree_receive_products.id = #{@receive_product.id} AND spree_inventory_units.po_version > 0
      #        GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")
      #
      #  @backorder_inventory_units = InventoryUnit.find_by_sql(
      #      "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
      #        INNER JOIN spree_receive_items ON spree_receive_items.inventory_unit_id = spree_inventory_units.id
      #        INNER JOIN spree_receive_products ON spree_receive_products.id = spree_receive_items.receive_product_id
      #        WHERE spree_receive_products.id = #{@receive_product.id} AND spree_inventory_units.po_version = 0
      #        GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")
      #
      #end

      def load_receive_item_by_receive_product
        @pending_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units . * , COUNT( spree_inventory_units.variant_id ) AS quantity FROM spree_inventory_units
            INNER JOIN spree_receive_items ON spree_receive_items.inventory_unit_id = spree_inventory_units.id
            INNER JOIN spree_receive_products ON spree_receive_products.id = spree_receive_items.receive_product_id
            INNER JOIN spree_payments ON spree_payments.order_id = spree_inventory_units.order_id
            WHERE spree_receive_products.id = #{@receive_product.id}
            AND spree_inventory_units.po_version > 0
            GROUP BY order_id, variant_id, name, number, size, patch, season, team, shirt_type, sleeve
            ORDER BY spree_payments.updated_at DESC")

        @backorder_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units . * , COUNT( spree_inventory_units.variant_id ) AS quantity FROM spree_inventory_units
            INNER JOIN spree_receive_items ON spree_receive_items.inventory_unit_id = spree_inventory_units.id
            INNER JOIN spree_receive_products ON spree_receive_products.id = spree_receive_items.receive_product_id
            INNER JOIN spree_payments ON spree_payments.order_id = spree_inventory_units.order_id
            WHERE spree_receive_products.id = #{@receive_product.id}
            AND spree_inventory_units.po_version = 0
            GROUP BY order_id, variant_id, name, number, size, patch, season, team, shirt_type, sleeve
            ORDER BY spree_payments.updated_at DESC")
      end

    end
  end
end