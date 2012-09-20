module Spree
  class PurchaseOrder < ActiveRecord::Base


    has_many :purchase_items, :dependent => :delete_all
    has_many :inventory_units, :through => :purchase_items

    has_many :receive_products, :dependent => :destroy

    has_many :refunds


    has_many :state_changes, :as => :stateful

    belongs_to :supplier

    accepts_nested_attributes_for :purchase_items
    accepts_nested_attributes_for :receive_products
    accepts_nested_attributes_for :inventory_units

    attr_accessible :number , :supplier_id

    before_create :generate_purchase_order_number

    make_permalink :field => :number

    def to_param
      number.to_s.parameterize.upcase
    end

    scope :by_number, lambda { |number| where(:number => number) }
    scope :between, lambda { |*dates| where('created_at BETWEEN ? AND ?', dates.first.to_date, dates.last.to_date) }
    #scope :by_supplier, lambda { |customer| joins(:user).where("#{Spree::User.table_name}.email = ?", customer) }
    scope :by_state, lambda { |state| where(:state => state) }

    scope :purchased, where(:state => 'purchased')
    scope :received, where(:state => 'received')

    scope :by_inventory_unit, lambda { |id| joins(:purchase_items).where("spree_purchase_items.inventory_unit_id = ?", id)}

    # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'wait_printing', :use_transactions => false do
      event :purchased do
        transition :from => 'wait_printing', :to => 'purchased'
        transition :from => 'received', :to => 'purchased'
      end
      event :received do
        transition :from => 'purchased', :to => 'received'
      end

    end

    private

    def generate_purchase_order_number
      record = true
      while record
        random = "P#{SecureRandom.hex(3).to_s.upcase}"
        record = self.class.where(:number => random).first
      end
      self.number = random
      self.number
    end

  end
end
