source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rake'
gem 'rails', '3.2.3'

gem 'mysql2', '0.3.10'


# FUNCTIONALITY
# ===============================================================
gem 'codemirror-rails'  # Text editor
gem 'treetop'           # Treetop to drive the grammar
gem 'mechanize'         # For to run the tests
gem 'resque', :require => 'resque/server' # Message queue
gem 'rspreedly'         # Spreedly for payments
gem 'devise'            # Authentication management with devise
gem 'public_suffix'     # For deciding whether domains are unique
gem 'kaminari'          # Pagination


# ADMIN and MONITORING
# ===============================================================
gem 'activeadmin'
gem "meta_search",  '>= 1.1.0.pre'
gem "formtastic",   "~> 2.1.1"

gem 'rails_exception_handler'   # Nicer exception reporting
gem 'exception_notification'    # Exception emails

gem 'rack-mini-profiler'        # Displays a breakdown of load times down the stack on dev


# HTML / CSS / JS
# ===============================================================
# Gems used in all environments
gem 'haml'
gem 'haml_rails'
gem 'jquery-rails'
gem 'therubyracer'
# therubyracer is a js runtime, required for the asset pipeline on systems 
# which don't have a built-in js runtime. therubyracer apparently very memory-intensive, 
# we should try and replace it with something better (e.g. Mustang), but attempts 
# have so far been unsuccessful

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',     '~> 3.2.0'
  gem 'bootstrap-sass', '~> 2.1.1'
  gem 'coffee-rails',   '~> 3.2.0'
  gem 'uglifier'
end


# TESTING and DEBUG
# ===============================================================
group :development, :test do
   gem 'rspec-rails'
end

group :development do
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-livereload'
  gem 'spork', '> 0.9.0.rc'
  gem 'awesome_print'
  gem 'jnunemaker-crack'
  gem 'pry_debug'
  
  # gems to notify guard of file changes - see https://github.com/guard/guard:
  gem 'rb-inotify', :require => false # Linux
  gem 'rb-fsevent', :require => false # OSX
  gem 'rb-fchange', :require => false # Window
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'capybara'
  gem 'factory_girl_rails', '~> 1.2'
end