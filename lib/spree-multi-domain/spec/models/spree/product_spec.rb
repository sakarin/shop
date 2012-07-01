require 'spec_helper'

describe Spree::Product do

  before(:each) do
    @store = Factory(:store)
    @product = Factory(:product, :stores => [@store])
    
    @product2 = Factory(:product, :permalink => 'something else')
  end
  
  it 'should correctly find products by store' do
    products_by_store = Spree::Product.by_store(@store).all

    products_by_store.should include(@product)
    products_by_store.should_not include(@product2)
  end
end
