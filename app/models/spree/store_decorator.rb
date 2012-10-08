module Spree
  Store.class_eval do
    has_and_belongs_to_many :pages, :join_table => 'spree_pages_stores'

    attr_accessible :seo_title, :shop_for_vip, :allow_user_login, :mail_username, :mail_password

    has_one :user

  end
end
