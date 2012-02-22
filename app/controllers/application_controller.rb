class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # When devise logs the user in, it does so with the User resource, so we need to correct the "/user" part of the URL to match the page you're actually going to
  def after_sign_in_path_for(resource)
     stored_location_for(resource) || test_files_path
   end

end
