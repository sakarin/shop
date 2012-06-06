module Spree
  module Admin
    class RefundsController < Spree::Admin::BaseController

      before_filter :load_purchase_order
      before_filter :load_refund, :only => [:edit, :update, :destroy, :fire]


      respond_to :html

      def index
        @refunds = @purchase_order.refunds
        respond_with(@refunds)
      end

      def new
        load_purchase_order_item
      end

      def create
        build_refund

        if @refund.save


          # get inventory from new
          (params[:units] || []).each do |unit|
            @unit = InventoryUnit.find(unit[0])
            max = (params[:unit_quantity][unit[0]]).to_i
            # find inventory unit with max quantity
            @units = InventoryUnit.where(:state => @unit.state, :variant_id => @unit.variant_id, :name => @unit.name, :number => @unit.number, :size => @unit.size, :patch => @unit.patch, :season => @unit.season, :team => @unit.team, :shirt_type => @unit.shirt_type, :sleeve => @unit.sleeve).limit(max)

            (@units || []).each do |inventory_unit|
              RefundItem.create(:refund_id => @refund.id, :inventory_unit_id => inventory_unit.id)
            end
          end

          flash[:notice] = flash_message_for(@refund, :successfully_created)
          respond_with(@refund) do |format|
            format.html { redirect_to edit_admin_purchase_order_refund_path(@purchase_order, @refund) }
          end
        else
          respond_with(@refund) { |format| format.html { render :action => 'new' } }
        end

      end

      def edit
        load_refund_item_by_refund_product
      end

      def update

      end

      def destroy

      end

      def fire
        if @refund.send("#{params[:e]}")
          flash.notice = t(:refund_updated)
        else
          flash[:error] = t(:cannot_perform_operation)
        end

        respond_with(@refund) { |format| format.html { redirect_to :back } }
      end



      private

      def build_refund
        @refund = @purchase_order.refunds.build
      end

      def load_purchase_order
        @purchase_order = PurchaseOrder.find_by_number(params[:purchase_order_id]) if params[:purchase_order_id]
      end

      def load_refund
        @refund = Refund.find_by_number(params[:id])
        @refund
      end

      def load_purchase_order_item
        @pending_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version > 0
                    AND spree_inventory_units.state LIKE 'backordered'
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")

        @backorder_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_purchase_items ON spree_purchase_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_purchase_orders ON spree_purchase_orders.id = spree_purchase_items.purchase_order_id
              WHERE spree_purchase_orders.id = #{@purchase_order.id} AND spree_inventory_units.po_version = 0
                    AND spree_inventory_units.state LIKE 'backordered'
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")

      end


      def load_refund_item_by_refund_product
        @pending_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_refund_items ON spree_refund_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_refunds ON spree_refunds.id = spree_refund_items.refund_id
              WHERE spree_refunds.id = #{@refund.id} AND spree_inventory_units.po_version > 0
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")

        @backorder_inventory_units = InventoryUnit.find_by_sql(
            "SELECT spree_inventory_units.*, count(spree_inventory_units.variant_id) as quantity FROM spree_inventory_units
              INNER JOIN spree_refund_items ON spree_refund_items.inventory_unit_id = spree_inventory_units.id
              INNER JOIN spree_refunds ON spree_refunds.id = spree_refund_items.refund_id
              WHERE spree_refunds.id = #{@refund.id} AND spree_inventory_units.po_version = 0
              GROUP BY variant_id, name, number, size, patch, season, team, shirt_type, sleeve")

      end

    end
  end
end