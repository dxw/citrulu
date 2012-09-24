# token_authentications_controller.rb

class TokenAuthenticationsController < ApplicationController 

  def create
    current_user.reset_authentication_token!
    redirect_to edit_user_registration_path + '#api_key'
  end

  def destroy
    current_user.authentication_token = nil
    current_user.save
    redirect_to edit_user_registration_path + '#api_key'
  end

end
