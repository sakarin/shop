    Deface::Override.new(:virtual_path => "spree/products/_cart_form",
                         :name => "converted_product_price_290656527",
                         :insert_after => "[data-hook='inside_product_cart_form'], #inside_product_cart_form[data-hook]",
                         :partial => "spree/products/customizations")
