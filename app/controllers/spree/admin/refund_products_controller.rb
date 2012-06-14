module Spree
  module Admin
    class RefundProductsController < Spree::Admin::BaseController

      before_filter :load_refund_product, :only => [:show, :fire]

      respond_to :html
      def index
         @refund_products = RefundProduct.authorized
      end



      def show
        @inventory_units = @refund_product.inventory_units
      end

      def fire
        if @refund_product.send("#{params[:e]}")
          flash.notice = t(:refund_product_updated)
        else
          flash[:error] = t(:cannot_perform_operation)
        end

        respond_with(@refund_product) { |format| format.html { redirect_to :back } }
      end

      private
      def load_refund_product
        @refund_product = RefundProduct.find_by_number(params[:id])
        @refund_product
      end




    end
  end
end