require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/admin/'
  add_filter '/vendor/'
end

require 'pry' # specs need debugging sometimes too!

require "rails/application"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# This line loads the seeds into the test db. The seeds connect to Spreedly so this is probably not a great idea, so instead we've done a global before :all (see bottom of file) to set up the default plan
# load File.expand_path("../../db/seeds.rb", __FILE__)
# http://stackoverflow.com/questions/1574797/how-to-load-dbseed-data-into-test-database-automatically

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # If any specs have a "focus" tag - only run those specs
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Include Devise helpers and a module which uses them
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
end

# load everything in lib/grammar
Dir["#{Rails.root}/lib/grammar/*.rb"].each { |f| load f }
Dir["#{Rails.root}/lib/*.rb"].each { |f| load f }

# Global test setup:
RSpec.configure do |config|
  config.before(:all) { FactoryGirl.create(:plan, default:true) }
  config.before(:each) {}
  config.after(:all) {}
  config.after(:each) {}
end

