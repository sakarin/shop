Deface::Override.new(
    :virtual_path => "spree/admin/configurations/index",
    :name => "supplier_admin_configurations_menu",
    :insert_bottom => "[data-hook='admin_configurations_menu']",
    :text => "<%= configurations_menu_item(I18n.t('supplier_admin'), admin_suppliers_url, I18n.t('manage_suppliers')) %>",
    :disabled => false)


Deface::Override.new(
    :virtual_path => "spree/admin/products",
    :name => "remove_product_from_prototype",
    :replace => "[data-hook='product-from-prototype']",
    :text => "Hello world",
    :disabled => false)



