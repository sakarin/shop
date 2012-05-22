module Spree
  AppConfiguration.class_eval do
    #preference :admin_ip, :string, :default => ''
    preference :auto_capture, :boolean, :default => true # automatically capture the creditcard (as opposed to just authorize and capture later)

    #preference :track_inventory_levels, :boolean, :default => false


  end
end