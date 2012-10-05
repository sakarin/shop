source 'https://rubygems.org'

gem 'rails', '3.2.3'

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


# see the notes in spree_flexi_variants
#gem 'rmagick'
gem 'carrierwave'
gem 'spree_flexi_variants', :path => 'lib/spree_flexi_variants'

gem "spreadsheet", "~> 0.6.5.9"
gem 'to_xls', "~> 1.0.0"

gem "pdfkit"
gem "wkhtmltopdf-binary"
gem 'spree_faq', :path => 'lib/spree-faq'
gem "paperclip", "~> 2.7.0"

group :production do
  gem 'exception_notification', :require => 'exception_notifier'
  gem 'mysql2', '0.3.10'
  #gem 'spree_paypal_adaptive_payment', :git => 'git://github.com/sakarin/spree_paypal_adaptive_payment.git'
end

#gem 'spree_paypal_express'  , :git => 'git://github.com/spree/spree_paypal_express.git'
gem 'spree_paypal_express', :path => 'lib/spree_paypal_express'

#- git => git://github.com/spree/spree-multi-domain.git
gem 'spree_multi_domain', :path => 'lib/spree-multi-domain'
#gem  'spree_multi_domain', :git => 'git://github.com/ramkalari/spree-multi-domain.git'

# git://github.com/martinjlowm/spree-multi-currency.git
gem 'multi_currencies', :path => 'lib/spree-multi-currency'

#gem 'spree_static_content', :git => 'git@github.com:spree/spree_static_content.git', :branch => '1-1-stable'
gem 'spree_static_content', :path => 'lib/spree_static_content'

#gem 'spree_static_content', :path => 'lib/spree_static_content'
gem 'spree_editor', :git => 'git://github.com/spree/spree_editor.git'
gem 'tinymce-rails', '>= 3.4.7.0.1'

group :development do
  #gem 'spree_paypal_invoice', :path => 'lib/spree_paypal_invoice'
end

gem 'paypal_nvp', :git => 'git://github.com/solisoft/paypal_nvp.git'

gem 'tinymce-rails-imageupload', :git => 'git://github.com/PerfectlyNormal/tinymce-rails-imageupload.git'

# gem for location block
gem "spree_geo_block", :path => "lib/spree_geo_block/"
gem 'geokit-rails3'

