module Spree
  class Refund < ActiveRecord::Base
    # attr_accessible :title, :body

    has_many :refund_items, :dependent => :delete_all
    has_many :inventory_units, :through => :refund_items

    belongs_to :purchase_order

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

      refund = InventoryUnit.find_by_sql("
                    SELECT spree_orders.id, spree_orders.number as number, spree_inventory_units.state, sum(spree_line_items.price) as amount FROM spree_inventory_units
                    INNER JOIN spree_orders ON spree_orders.id = spree_inventory_units.order_id
                    INNER JOIN spree_refund_items ON spree_refund_items.inventory_unit_id = spree_inventory_units.id
                    INNER JOIN spree_refunds ON spree_refunds.id = spree_refund_items.refund_id
                    INNER JOIN spree_line_items ON (spree_line_items.variant_id = spree_inventory_units.variant_id AND spree_line_items.order_id = spree_inventory_units.order_id)
                    WHERE spree_refunds.id = #{self.id}
                    GROUP BY spree_orders.id
                    ")

      (refund || []).each do |refund|
        refund_product = RefundProduct.create(:order_id => refund.id, :amount => refund.amount)

        items = InventoryUnit.find_by_sql("
                      SELECT spree_inventory_units.* FROM spree_inventory_units
                      INNER JOIN spree_orders ON spree_orders.id = spree_inventory_units.order_id
                      INNER JOIN spree_refund_items ON spree_refund_items.inventory_unit_id = spree_inventory_units.id
                      INNER JOIN spree_refunds ON spree_refunds.id = spree_refund_items.refund_id
                      WHERE spree_orders.id = #{refund.id}
                                          ")

        (items || []).each do |item|
          item.update_attributes(:refund_product_id => refund_product.id)
        end

      end

    end

    def generate_receive_product_number
      record = true
      while record
        random = "F#{Array.new(9) { rand(9) }.join}"
        record = self.class.find(:first, :conditions => ["number = ?", random])
      end
      self.number = random if self.number.blank?
      self.number
    end

  end
end
