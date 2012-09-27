module Spree
  class Refund < ActiveRecord::Base
    # attr_accessible :title, :body

    has_one :refund_product

    has_many :refund_items, :dependent => :delete_all
    has_many :inventory_units, :through => :refund_items

    belongs_to :order


    has_many :state_changes, :as => :stateful

    before_create :generate_receive_product_number

    make_permalink :field => :number

    scope :authorized, where(:state => 'authorized')
    scope :approve, where(:state => 'approved')

    def to_param
      number.to_s.parameterize.upcase
    end

    # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'authorized', :use_transactions => false do

      event :approve do
        transition :from => 'authorized', :to => 'approve'
      end
      after_transition :to => 'approve', :do => :after_approve
    end

    private

    def after_approve

      refund_items = inventory_units.find_by_sql("
                      SELECT spree_inventory_units.* FROM spree_inventory_units
                      INNER JOIN spree_orders ON spree_orders.id = spree_inventory_units.order_id
                      INNER JOIN spree_refund_items ON spree_refund_items.inventory_unit_id = spree_inventory_units.id
                      INNER JOIN spree_refunds ON spree_refunds.id = spree_refund_items.refund_id
                      WHERE spree_refunds.id = #{self.id} ")
      refund_amount = 0
      refund_items.each do |item|
        line_item = LineItem.find_by_variant_id_and_order_id(item.variant_id, item.order_id)
        refund_amount += line_item.price
      end

      refund_product = RefundProduct.create(:order_id => refund_items.last.order_id, :refund_id => self.id, :amount => refund_amount)

      refund_product.reload
      #refund_items.each do |item|
      #  item.update_attributes(:refund_product_id => refund_product.id)
      #end
      self.inventory_units.each &:refund



    end



    def generate_receive_product_number
      record = true
      while record
        random = "F#{SecureRandom.hex(3).to_s.upcase}"
        record = self.class.where(:number => random).first
      end
      self.number = random
      self.number
    end

  end
end
