module Spree
  module ApplicationHelper
    def site_title
      self.current_store.nil? ? "" : self.current_store.seo_title
    end
  end
end
