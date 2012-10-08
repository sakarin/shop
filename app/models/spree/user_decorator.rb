Spree::User.class_eval do

  attr_accessible :vip, :vip_at, :store_id

  belongs_to :store

end