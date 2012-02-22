source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem 'sqlite3'

# Authentication management with devise:
gem 'devise'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'haml'
  gem 'haml_rails'
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'bootstrap-sass', '~> 2.0.1'
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

group :development, :test do
   gem 'rspec-rails'
   gem 'capybara'
   gem "factory_girl_rails", "~> 1.2"
   gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
   gem 'guard-rspec'
   gem 'guard-livereload'
end

# group :test do
#   # Pretty printed test output
#   gem 'turn', :require => false
# end
