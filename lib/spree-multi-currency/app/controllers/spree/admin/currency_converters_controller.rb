module Spree
  class Admin::CurrencyConvertersController < Spree::Admin::ResourceController


    private
    def collection
      @collection = CurrencyConverter.page(params[:page]).per(15)
    end
  end
end
