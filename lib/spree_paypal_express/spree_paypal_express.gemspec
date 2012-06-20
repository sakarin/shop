Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_paypal_express'
  s.version     = '1.1.0'
  s.summary     = 'Adds PayPal Express as a Payment Method to Spree store'
  s.homepage    = 'http://www.spreecommerce.com'
  s.author      = 'Spree Commerce'
  s.email       = 'gems@spreecommerce.com'
  s.required_ruby_version = '>= 1.8.7'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.has_rdoc      = false

  s.add_dependency('spree_core', '>=1.0.0')
  s.add_development_dependency('rspec-rails')
end
