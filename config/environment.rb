# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SimpleFrontEndTesting::Application.initialize!

# Tell Haml to generate html5
Haml::Template.options[:format] = :html5
