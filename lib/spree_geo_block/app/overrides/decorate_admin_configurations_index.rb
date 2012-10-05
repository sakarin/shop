Deface::Override.new(
    :virtual_path => "spree/admin/configurations/index",
    :name => "geo_block_admin_configurations_menu",
    :insert_bottom => "[data-hook='admin_configurations_menu']",
    :text => "<%= configurations_menu_item(I18n.t('locations_admin'), admin_locations_url, I18n.t('manage_locations')) %>",
    :disabled => false)