SpreeApp
========

Introduction goes here.


Example
=======

Install
-------
bundle exec rails g spree_app:install

Example goes here.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2012 [name of extension creator], released under the New BSD License


Configuration
=============
admin->product->option type
Name                    Presentation
------------------------------------
shirt-size              Size
shirt-patch             Patch

admin->product->properties
Name                    Presentation
------------------------------------
shirt-season            Season
shirt-team              Team
shirt-name              Name
shirt-number            Number
shirt-type              Type
shirt-sleeve            Sleeve


admin->product-customization type
Name                    Presentation
------------------------------------
shirt-name              Name       -> Calculator = Engraving Calculator, Price Per Letter = 0.0  | Customizable Options->Name = inscription, Customizable Options->Presentation = Name
shirt-number            Number     -> Calculator = Engraving Calculator, Price Per Letter = 0.0  | Customizable Options->Name = inscription, Customizable Options->Presentation = Number





admin->product->Properties
------------------------------------
Name
  Football Shirt
Properties
  shirt-name  shirt-number  shirt-season  shirt-sleeve  shirt-team  shirt-type
Option Types
  shirt-size  shirt-patch


Free Shipping
------------------------------------
1. Create Shipping Category -> Name = 'Free Shipping'
2. In product select Shipping Category to Free Shipping

-------------------------------------------------------------------------------------------------------------
Official PayPal Express for Spree
-------------------------------------------------------------------------------------------------------------
Installation
1. Add the following line to your application's Gemfile

 gem "spree_paypal_express", :git => "git://github.com/spree/spree_paypal_express.git"
Note: The :git option is only required for the edge version, and can be removed to used the released gem.

2. Run bundler

  bundle install
3. Copy assets / migrations

  rake railties:install:migrations
  rake db:migrate

  OR

  rails g spree_paypal_express:install


Configuration
1. Server: test for Development OR production for Production

Note: config for auto capture

config->initializers->spree.rb
Spree::Config.set(:auto_capture => true)

/----------------------------------------------------------------------------------------------
/- spree-multi-domain
/----------------------------------------------------------------------------------------------
git://github.com/spree/spree-multi-domain.git

rails g spree_multi_domain:install

/----------------------------------------------------------------------------------------------
/- ERROR - libmysqlclient.18.dylib For Development
/----------------------------------------------------------------------------------------------
sudo install_name_tool -change libmysqlclient.18.dylib /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/local/rvm/gems/ruby-1.9.2-p290/gems/mysql2-0.2.13/lib/mysql2/mysql2.bundle



ActionController::Base.asset_host = "shop1:3000"

rake db:migrate RAILS_ENV="production"


# Config Mysql for Development
sudo ln -s /Applications/MAMP/tmp/mysql/mysql.sock /tmp/mysql.sock


# Clear Log
1. rake log:clear
2. service apache2 restart

/----------------------------------------------------------------------------------------------
/- spree-multi-currency
/----------------------------------------------------------------------------------------------
git://github.com/pronix/spree-multi-currency.git

bundle exec rake multi_currencies:install

Load currencies
1. rake multi_currencies:currency:iso4217



The argument in square brackets is the iso code of your basic currency, so to load rates when US Dollar is your basic currency, use

->
rake 'multi_currencies:rates:google[GBP]'

if you want change rates GBP to main currency

1.  rake multi_currencies:rates:google gbp  RAILS_ENV="production"
2.  goto admin->configuration->currency setting-> set basic to gbp

