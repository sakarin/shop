module Spree
  HomeController.class_eval do
    #load_and_authorize_resource

    before_filter :determine_store


    private

    def determine_store

      if @current_store && current_user.nil?
        redirect_to login_path
      end


    end

  end


end
