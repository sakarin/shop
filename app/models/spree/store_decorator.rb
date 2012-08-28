module Spree
  Store.class_eval do
    attr_accessible :seo_title, :shop_for_vip
  end
end
