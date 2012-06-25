source 'https://rubygems.org'

gem 'rails','3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'spree'

gem 'spree_usa_epay'
gem 'spree_skrill'

#gem 'spree_app', :path => 'lib/spree_app'

# see the notes in spree_flexi_variants
#gem 'rmagick'
gem 'carrierwave'
gem 'spree_flexi_variants', :path => 'lib/spree_flexi_variants'
#gem 'spree_flexi_variants' , :git=>'git://github.com/jsqu99/spree_flexi_variants.git'


gem "spreadsheet", "~> 0.6.5.9"
gem 'to_xls', "~> 1.0.0"


gem "pdfkit"
gem "wkhtmltopdf-binary"

group :production do
  gem 'exception_notification', :require => 'exception_notifier'
  gem 'mysql2', '0.3.10'
end

#gem 'spree_paypal_express'  , :git => 'git://github.com/spree/spree_paypal_express.git'
gem 'spree_paypal_express'  , :path => 'lib/spree_paypal_express'


#- git => git://github.com/spree/spree-multi-domain.git
gem  'spree_multi_domain', :path => 'lib/spree-multi-domain'
#gem  'spree_multi_domain', :git => 'git://github.com/ramkalari/spree-multi-domain.git'

# git://github.com/martinjlowm/spree-multi-currency.git
gem  'multi_currencies', :path => 'lib/spree-multi-currency'

