module Spree
  class Location < ActiveRecord::Base
    belongs_to :payment_method
    attr_accessible :name, :payment_method_id, :country
    validates_presence_of :name


  end
end

