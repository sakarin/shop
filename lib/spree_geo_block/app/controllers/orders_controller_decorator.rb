Spree::OrdersController.class_eval do
  before_filter :location_block, :only => :edit



end
