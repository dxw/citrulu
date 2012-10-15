class RegistrationsController < Devise::RegistrationsController

  # Copied verbatim from the devise code on 04/09/2012 in order to put log_event messages in
  def create
    build_resource
    if resource.save
      log_event("signed up")
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected
  
  # after the user signs up, they'll need to confirm their email address 
  def after_inactive_sign_up_path_for(resource)
    new_session_path(resource)
  end
  
  def user_url(resource)
    edit_registration_url(resource)
  end
  
  def after_update_path_for(resource)
    edit_registration_path(resource)
  end
end