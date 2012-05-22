module Spree
  class Supplier < ActiveRecord::Base
    # attr_accessible :title, :body


    has_many :purchase_orders

    attr_accessible :name, :email, :code
    attr_accessible :purchase_orders_attributes

    accepts_nested_attributes_for :purchase_orders

  end
end
