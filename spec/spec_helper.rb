require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/app/admin/'
end

require 'pry' # specs need debugging sometimes too!

require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require "rails/application"
    
  # Prevent Devise from loading the User model super early with it's route hacks for Rails 3.1 rc4
  # see also: https://github.com/timcharper/spork/wiki/Spork.trap_method-Jujutsu
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

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
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
  
  # Reload everything in lib/grammar
  Dir["#{Rails.root}/lib/grammar/*.rb"].each { |f| load f }
  Dir["#{Rails.root}/lib/*.rb"].each { |f| load f }
  
  # Hack to ensure models get reloaded by Spork - remove as soon as this is fixed in Spork.
  # Silence warnings to avoid all the 'warning: already initialized constant' messages that
  # appear for constants defined in the models.
  silence_warnings do
    Dir["#{Rails.root}/app/models/**/*.rb"].each {|f| load f}
  end
  
  # Global test setup:
  RSpec.configure do |config|
    config.before(:all) { FactoryGirl.create(:plan, default:true) }
    config.before(:each) {}
    config.after(:all) {}
    config.after(:each) {}
  end
  
end

