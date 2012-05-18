module Spree
  class Supplier < ActiveRecord::Base
    # attr_accessible :title, :body
    attr_accessible :name, :email, :code
  end
end
