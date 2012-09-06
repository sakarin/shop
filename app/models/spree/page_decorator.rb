Spree::Page.class_eval do
  attr_accessible :store_ids
  has_and_belongs_to_many :stores, :join_table => 'spree_pages_stores'
  scope :by_store, lambda {|store| joins(:stores).where("spree_pages_stores.store_id = ?", store)}
end
