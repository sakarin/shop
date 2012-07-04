module Spree
  class CurrencyConverter < ActiveRecord::Base

    attr_accessible :nominal, :value, :date_req, :currency
    belongs_to :currency
    default_scope :order => "spree_currency_converters.date_req ASC"

    class << self
      def add(currency, date, value, nominal)
        create({:nominal => nominal, :value => value, :date_req => date, :currency => currency})
      end
    end
  end
end
