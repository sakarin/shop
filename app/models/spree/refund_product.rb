module Spree
  class RefundProduct < ActiveRecord::Base

    belongs_to :order
    has_many :inventory_units
    before_create :generate_number
    before_save :force_positive_amount

    make_permalink :field => :number

    def to_param
      number.to_s.parameterize.upcase
    end

    validates :order, :presence => true
    validates :amount, :numericality => true

    scope :approved, where(:state => 'approved')
    scope :authorized, where(:state => 'authorized')


    attr_accessible :order_id, :amount, :reason

    state_machine :initial => 'authorized' do
      after_transition :to => 'approved', :do => :process_approved

      event :approve do
        transition :to => 'approved', :from => 'authorized'
      end
      event :cancel do
        transition :to => 'canceled', :from => 'authorized'
      end
    end



    private



    def generate_number
      record = true
      while record
        random = "T#{SecureRandom.hex(3).to_s.upcase}"
        record = self.class.where(:number => random).first
      end
      self.number = random
      self.number
    end

    def process_approved
      inventory_units.each &:refund!
      credit = Adjustment.create({:source => self, :adjustable => order, :amount => amount.abs * -1, :label => I18n.t(:rma_credit)}, :without_protection => true)
      #order.update!
    end





    def force_positive_amount
      self.amount = amount.abs
    end
  end
end
