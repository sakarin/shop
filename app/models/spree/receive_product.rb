module Spree
  class ReceiveProduct < ActiveRecord::Base
    # attr_accessible :title, :body

    has_many :receive_items, :dependent => :destroy
    has_many :inventory_units, :through => :receive_items

    belongs_to :purchase_order

    has_many :state_changes, :as => :stateful

    before_create :generate_receive_product_number

    after_create :after_received

    make_permalink :field => :number

    def to_param
      number.to_s.parameterize.upcase
    end


    # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'received', :use_transactions => false do

      event :received do
        transition :from => 'purchased', :to => 'received'
      end

    end

    private

    def after_received
      self.purchase_order.received
    end

    def generate_receive_product_number
      record = true
      while record
        random = "I#{SecureRandom.hex(3).to_s.upcase}"
        record = self.class.find(:first, :conditions => ["number = ?", random])
      end
      self.number = random
      self.number
    end


  end
end
