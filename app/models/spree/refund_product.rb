module Spree
  class RefundProduct < ActiveRecord::Base

    belongs_to :order
    has_many :inventory_units
    before_create :generate_number
    before_save :force_positive_amount
    after_create :process_create_credit

    make_permalink :field => :number

    def to_param
      number.to_s.parameterize.upcase
    end

    validates :order, :presence => true
    validates :amount, :numericality => true

    scope :paid, where(:state => 'paid')
    scope :authorized, where(:state => 'authorized')


    attr_accessible :order_id, :amount, :reason

    state_machine :initial => 'authorized' do
      after_transition :to => 'paid', :do => :process_paid

      event :paid do
        transition :to => 'paid', :from => 'authorized'
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

    def process_create_credit

      adjust_amount = Currency.convert(amount, order.base_currency, "GBP")
      credit = Adjustment.create({:source => self, :adjustable => order, :amount => adjust_amount.abs * -1, :label => I18n.t(:rma_credit)}, :without_protection => true)
      order.update!
    end

    def process_paid
      @order = self.order
      @payment = Payment.new
      @payment.amount = @order.outstanding_balance
      @payment.order= @order
      @payment.payment_method_id= 1
      @payment.payment_method= PaymentMethod.find_by_type("Spree::PaymentMethod::Check")

      begin
        unless @payment.save
          return
        end
        @payment.capture!

        if @order.completed?
          @payment.process!

        else
          #This is the first payment (admin created order)
          until @order.completed?
            @order.next!
          end

        end

      rescue Spree::Core::GatewayError => e

      end

    end

    def force_positive_amount
      self.amount = amount.abs
    end
  end
end
