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



