module Spree
  AppConfiguration.class_eval do
    #preference :admin_ip, :string, :default => ''
    preference :auto_capture, :boolean, :default => true # automatically capture the creditcard (as opposed to just authorize and capture later)

    preference :first_item_shipping_cost, :integer, :default => 8
    preference :additional_item_shipping_cost, :integer, :default => 6
    preference :free_shipment_text, :string, :default => "Free Shipping"


  end
end