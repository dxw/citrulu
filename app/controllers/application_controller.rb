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
  def log_event(category, action, lab=nil, value=nil)
    session[:events] ||= Array.new
    session[:events] << { category: category, action: action, label: lab, value: value }
  end
  
  def log_event_if_first(user, category, action, *args)
    meta_name = (category+ " " + action).parameterize("_")
    User.define_meta_methods(meta_name)
    
    # If a meta flag exists, then it's not the first time for this event:
    unless user.send(meta_name)
      user.send("#{meta_name}=", true)
      log_event(category, action, *args)
    end
  end
end
