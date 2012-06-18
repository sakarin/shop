module Spree
  class ShipmentFile < ActiveRecord::Base
    # attr_accessible :title, :body
    attr_accessible :name
    before_create :generate_number


    def generate_number
      record = true
      while record
        random = "H#{SecureRandom.hex(3).to_s.upcase}"
        record = self.class.where(:name => random).first
      end
      self.name = random
      self.name
    end

  end
end
