module Spree
  module ApplicationHelper
    def site_title

      if !@taxon.nil? && !@taxon.title.blank?
        @taxon.title
      elsif @product.nil? || @product.title.blank?
        self.current_store.nil? ? "" : self.current_store.seo_title
      else
         @product.title
      end


    end
  end
end
