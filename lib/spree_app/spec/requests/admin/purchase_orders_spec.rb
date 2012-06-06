require 'spec_helper'

describe "Purchase Orders" do

  #@product = create(:product, :name => "RoR Mug")
  #@product.on_hand = 1
  #@product.save

  it "purchase orders" do
    create(:supplier, :name => "supplier test")
    visit spree.admin_purchase_orders_path
    click_link "new purchase order"
    page.should have_content("successfully created")
  end


end
