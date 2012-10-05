ApplicationController.class_eval do
  def location_block

    # Geo For Test
    # http://www.geoiptool.com/

    # -------------------------------------------------------------------
    # US (USA)
    # -------------------------------------------------------------------
    #Provider: geoPlugin
    #Street:
    #City: Springfield
    #State: MO
    #Zip:
    #Latitude: 37.215301513672
    #Longitude: -93.298202514648
    #Country: US
    #Success: true
    # -------------------------------------------------------------------
    #@geo = Geokit::Geocoders::MultiGeocoder.geocode("99.115.114.78")
   # @geo =Geokit::Geocoders::MultiGeocoder.geocode("17.172.224.47")

   # Thai
   #@geo = Geokit::Geocoders::MultiGeocoder.geocode("124.122.152.111")

    if Rails.env == "production"
      @geo = Geokit::Geocoders::MultiGeocoder.geocode(request.ip)
    else
      @geo = Geokit::Geocoders::MultiGeocoder.geocode("99.115.114.78")
    end


    if not Spree::Location.where(:country => @geo.country_code.upcase, :state => @geo.state.upcase, :city => @geo.city.upcase).blank?

      @location = Spree::Location.where(:country => @geo.country_code.upcase, :state => @geo.state.upcase, :city => @geo.city.upcase).last
      if @location.operator == "equal"
        redirect_to "#{@location.code}"
      end
    elsif not Spree::Location.where(:country => @geo.country_code.upcase, :state => @geo.state.upcase, :city => "").blank?
      @location = Spree::Location.where(:country => @geo.country_code.upcase, :state => @geo.state.upcase, :city => "").last
      if @location.operator == "equal"
        redirect_to "#{@location.code}"
      end
    elsif not Spree::Location.where(:country => @geo.country_code.upcase, :state => "", :city => "").blank?
      @location = Spree::Location.where(:country => @geo.country_code.upcase, :state => "", :city => "").last
      if @location.operator == "equal"
        redirect_to "#{@location.code}"
      end
    end


  end
end