Deface::Override.new(:virtual_path => "spree/admin/configurations/index",
                     :name => "config_admin_product_sub_tabs_203014347",
                     :insert_bottom => "[data-hook='admin_configurations_menu']",
                     :text => "<%= configurations_menu_item(I18n.t('product_customization_types'), admin_product_customization_types_url, I18n.t('product_customization_types')) %>",
                     :disabled => false)
