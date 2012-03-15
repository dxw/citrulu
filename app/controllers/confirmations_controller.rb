class ConfirmationsController < Devise::ConfirmationsController

  def show
    super
    
    if current_user then
      # They've been logged in, so must have been successfully confirmed:
      current_user.send_welcome_email
    end
  end

end