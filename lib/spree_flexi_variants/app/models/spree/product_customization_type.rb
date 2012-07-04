module Spree
  class ProductCustomizationType < ActiveRecord::Base
    calculated_adjustments  # does this just need to be changed to has_one :calculator?
    has_and_belongs_to_many :products
    has_many :customizable_product_options, :dependent => :destroy
    accepts_nested_attributes_for :customizable_product_options, :allow_destroy => true
    attr_accessible :name, :presentation, :description, :customizable_product_options_attributes
  end
end
