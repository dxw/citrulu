source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem 'sqlite3'

# Authentication management with devise:
gem 'devise'

# Text editor:
gem 'ace-rails-ap'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'haml'
  gem 'haml_rails'
  gem 'sass-rails', '  ~> 3.1.0'
  gem 'bootstrap-sass', '~> 2.0.1'
  gem 'coffee-rails', '~> 3.1.0'
  gem 'uglifier'
end

gem 'jquery-rails'

group :development do
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'guard-livereload'
end

group :test do
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'factory_girl_rails', '~> 1.2'
  gem 'spork', '> 0.9.0.rc'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
end

group :development, :test do
   gem 'rspec-rails'
end
