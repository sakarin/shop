Spree::UserSessionsController.class_eval do

  helper_method :current_store
  helper_method :current_tracker

  private

  def current_store
    @current_store ||= Spree::Store.current(request.host)
  end

  def current_tracker
    @current_tracker ||= Spree::Tracker.current(request.host)
  end


end