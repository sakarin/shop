module Spree
  class Excel < ActiveRecord::Base
    attr_accessible :attachment

    validates_attachment_content_type :attachment, :content_type => 'application/vnd.ms-excel'
    has_attached_file :attachment, :path => "#{Rails.root}/public/files/excels/:id/:basename.:extension"

  end
end