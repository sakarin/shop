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

    preference :price_per_letter, :decimal, :default => 3.0
    preference :auto_capture, :boolean, :default => true

    # Preferences related to image settings
    preference :attachment_default_url, :string, :default => '/products/:id/:style/:basename.:extension'
    preference :attachment_path, :string, :default => ':rails_root/public/products/:id/:style/:basename.:extension'
    preference :attachment_styles, :string, :default => "{\"mini\":\"48x48>\",\"small\":\"100x100>\",\"product\":\"240x240>\",\"large\":\"600x600>\"}"
    preference :attachment_default_style, :string, :default => 'product'
    preference :s3_access_key, :string
    preference :s3_bucket, :string
    preference :s3_secret, :string
    preference :s3_headers, :string, :default => "{\"Cache-Control\":\"max-age=31557600\"}"
    preference :use_s3, :boolean, :default => false # Use S3 for images rather than the file system




  end
end