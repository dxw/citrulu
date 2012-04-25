source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rake'
gem 'rails', '3.2.0'

# Pagination
gem 'bootstrap-will_paginate'

# Authentication management with devise:
gem 'devise'

# Text editor:
gem 'codemirror-rails'

# Treetop to drive the grammar:
gem 'treetop'

# Rails seems to depend on this
gem 'therubyracer'

# For to run the tests
gem 'mechanize'

# Gems used in all environments
gem 'haml'
gem 'haml_rails'
gem 'jquery-rails'

# Nicer exception reporting
gem 'rails_exception_handler'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '  ~> 3.2.0'
  gem 'bootstrap-sass', '~> 2.0.1'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier'
end

group :development do
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-livereload'
  gem 'awesome_print'
  gem 'jnunemaker-crack'
  gem 'pry'
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', :require => false
  gem 'capybara'
  gem 'factory_girl_rails', '~> 1.2'
  gem 'spork', '> 0.9.0.rc'
#  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'rb-fsevent', :require => false 
end

group :development, :test do
   gem 'rspec-rails'
   gem 'sqlite3'
end

group :production do
   gem 'mysql2', '0.3.10'
end
