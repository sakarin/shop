module Spree
  Taxon.class_eval do

    attr_accessible :title


    # Creates permalink based on Stringex's .to_url method
    def set_permalink
      if parent_id.nil?
        self.permalink = name.to_url if permalink.blank?
      else
        parent_taxon = Taxon.find(parent_id)
        self.permalink = [parent_taxon.permalink, (permalink.blank? ? name.to_url : permalink.split('/').last)].join('/')
      end
    end

    def get_title
      parent_taxon = Taxon.find(parent_id)
      [parent_taxon.permalink, (permalink.blank? ? name.to_url : permalink.split('/').last)].join(' ')
    end



  end
end
