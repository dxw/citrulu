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
  
  # Add an event for Google Analytics
  def log_event(event, properties = {})
    session[:events] ||= Array.new
    session[:events] << {name: event, properties: properties }
  end
  
  before_filter :get_controller_and_action
  
  def get_controller_and_action
    @controller_name = controller_name
    @action_name     = action_name 
  end
  
  
  def after_sign_out_path_for(resource)
    if Rails.env == 'production'
      "https://www.citrulu.com"
    else # Rails.env == 'development'
      "/sign_in"
    end
  end
  
end
