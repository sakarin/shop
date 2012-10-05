module Spree
  module Admin
    GeneralSettingsController.class_eval do
      def show
        @preferences = ['site_name', 'default_seo_title', 'default_meta_keywords',
                        'default_meta_description', 'site_url', 'admin_ip']
      end

      def edit
        @preferences = [:site_name, :default_seo_title, :default_meta_keywords,
                        :default_meta_description, :site_url, :admin_ip, :allow_ssl_in_production,
                        :allow_ssl_in_staging, :allow_ssl_in_development_and_test,
                        :check_for_spree_alerts]
      end

    end
  end
end


