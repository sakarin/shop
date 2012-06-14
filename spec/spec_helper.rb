# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'ffaker'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }





# Requires factories defined in spree_core
require 'database_cleaner'
require 'spree/core/testing_support/factories'
require 'spree/core/testing_support/env'
require 'spree/core/testing_support/controller_requests'
require 'spree/core/url_helpers'
require 'paperclip/matchers'

require 'factory_girl'

Dir[File.join(File.dirname(__FILE__), 'factories/**/*.rb')].each { |f| require f }

RSpec.configure do |config|


  config.include Spree::Core::UrlHelpers


  config.mock_with :rspec


  config.fixture_path = "#{::Rails.root}/spec/fixtures"


  config.use_transactional_fixtures = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::Core::UrlHelpers
  config.include Spree::Core::TestingSupport::ControllerRequests

  config.include Paperclip::Shoulda::Matchers

end
