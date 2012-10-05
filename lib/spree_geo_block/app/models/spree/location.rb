module Spree
  class Location < ActiveRecord::Base
    attr_accessible :operator, :name, :code, :country, :state, :zip, :city
    validates_presence_of :name
    OPERATOR = [:equal, :except]

  end
end

