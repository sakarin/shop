require 'spec_helper'

describe "Spree::Admin::SuppliersController" , :js => true do

  context "#index" do
    it "should be able to show supplier index" do
      visit spree.admin_suppliers_path
      page.should have_content("Supplier")

    end
  end

  context "#new" do
    it "should be able to create new supplier" do
      visit spree.admin_suppliers_path

      click_link "new supplier"
      fill_in "supplier_name", :with => "mow lawn"
      click_on "submit_create"
      page.should have_content("successfully created")

    end
  end

end