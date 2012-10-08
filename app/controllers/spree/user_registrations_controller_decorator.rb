Spree::UserRegistrationsController.class_eval do

  def create
    @user = build_resource(params[:user])
    @user.store = current_store
    if resource.save
      set_flash_message(:notice, :signed_up)
      sign_in(:user, @user)
      fire_event('spree.user.signup', :user => @user, :order => current_order(true))
      sign_in_and_redirect(:user, @user)
    else
      clean_up_passwords(resource)
      render :new
    end
  end

end