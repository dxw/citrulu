class RegistrationsController < Devise::RegistrationsController
  
  protected
  
  # after the user signs up, they'll need to confirm their email address 
  def after_inactive_sign_up_path_for(resource)
    new_session_path(resource)
  end
end