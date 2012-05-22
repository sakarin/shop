module Spree
  class PurchaseOrder < ActiveRecord::Base


    has_many :purchase_items, :dependent => :delete_all
    has_many :inventory_units, :through => :purchase_items


    has_many :state_changes, :as => :stateful

    belongs_to :supplier

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

    # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'wait_printing', :use_transactions => false do
      event :purchased do
        transition :from => 'wait_printing', :to => 'purchased'
      end
      event :received do
        transition :from => 'purchased', :to => 'received'
      end
      after_transition :to => 'received', :do => :after_received
    end

    private

    def generate_purchase_order_number
      record = true
      while record
        random = "PO#{Array.new(9) { rand(9) }.join}"
        record = self.class.find(:first, :conditions => ["number = ?", random])
      end
      self.number = random if self.number.blank?
      self.number
    end

    def after_received

    end

  end
end
