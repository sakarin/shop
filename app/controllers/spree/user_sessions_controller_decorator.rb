module Spree
  UserSessionsController.class_eval do


    helper_method :current_store
    helper_method :current_tracker


    def create
      authenticate_user!

      unless current_store.allow_user_login or current_user.nil? or current_user.has_role?('admin')
          redirect_to destroy_user_session_path
      else
        if user_signed_in?

          respond_to do |format|
            format.html {
              flash.notice = t(:logged_in_succesfully)
              redirect_back_or_default(products_path)
            }
            format.js {
              user = resource.record
              render :json => {:ship_address => user.ship_address, :bill_address => user.bill_address}.to_json
            }
          end
        else
          flash.now[:error] = t('devise.failure.invalid')
          render :new
        end
      end
    end

    private

    def current_store
      @current_store ||= Spree::Store.current(request.host)
    end

    def current_tracker
      @current_tracker ||= Spree::Tracker.current(request.host)
    end


  end
end