Deface::Override.new(
  :virtual_path => "spree/admin/pages/_form",
  :name => "multi_domain_admin_page_form_meta",
  :insert_bottom => "[id='static_page_options']",
  :partial => "spree/admin/pages/stores",
  :disabled => false)
