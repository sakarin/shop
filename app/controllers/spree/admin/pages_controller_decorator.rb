Spree::Admin::PagesController.class_eval do
  update.before :set_stores

  private
  def set_stores
    @page.store_ids = nil unless params[:page].key? :store_ids
  end

end
