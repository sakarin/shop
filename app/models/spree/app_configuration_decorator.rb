module Spree
  AppConfiguration.class_eval do


    preference :first_item_shipping_cost, :integer, :default => 8
    preference :additional_item_shipping_cost, :integer, :default => 6
    preference :free_shipment_text, :string, :default => "Free Shipping"

    preference :allow_ssl_in_development_and_test, :boolean, :default => false
    preference :allow_ssl_in_production, :boolean, :default => false
    preference :allow_ssl_in_staging, :boolean, :default => false

    preference :site_name, :string, :default => 'Demo Shop'
    preference :site_url, :string, :default => 'demo shop'
    preference :check_for_spree_alerts, :boolean, :default => false

    preference :default_meta_description, :string, :default => 'demo site'
    preference :default_meta_keywords, :string, :default => 'demo'




  end
end