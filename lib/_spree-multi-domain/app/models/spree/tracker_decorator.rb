Spree::Tracker.class_eval do
  belongs_to :store

  def self.current(domain)
    Spree::Tracker.where(:active => true, :environment => ENV['RAILS_ENV']).joins(:store).where("spree_stores.domains LIKE '%#{domain}%'").first
  end
end
