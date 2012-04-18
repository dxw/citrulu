class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # When devise logs the user in, it does so with the User resource, so we need to correct the "/user" part of the URL to match the page you're actually going to
  # def after_sign_in_path_for(resource)
  #    stored_location_for(resource) || "/test_file_editor"
  #  end

  helper_method :check_ownership

  def check_ownership(id, model)
    # If :id is numeric, assume it's an ID, otherwise let the page return a 404
    return nil if id == 0
    begin  
      raise ActiveRecord::RecordNotFound unless model.find(id).owner == current_user
    rescue ActiveRecord::RecordNotFound
      yield
    end
  end

  RELOAD_LIBS = Dir[Rails.root + 'lib/**/*.rb'] if Rails.env.development?

  before_filter :_reload_libs, :if => :_reload_libs?

  def _reload_libs
    puts "Reloading lib"
    RELOAD_LIBS.each do |lib|
      require_dependency lib
    end
  end

  def _reload_libs?
    defined? RELOAD_LIBS
  end
end
