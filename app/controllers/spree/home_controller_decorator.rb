module Spree
  HomeController.class_eval do


    before_filter :determine_store


    private

    def determine_store

      #if @current_store && current_user.nil?
      if @current_store.shop_for_vip? && current_user.nil?
        redirect_to login_path
      elsif @current_store.shop_for_vip? && !current_user.has_role?('vip')
        redirect_to destroy_user_session_path
      else

      end


    end

  end


end
