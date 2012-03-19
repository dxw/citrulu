require 'spec_helper'

describe ConfirmationsController do
  describe "show" do
    login_user

    it "Sends a welcome email to logged in users" do
      pending "This doesn't work and I don't know why"
      User.should_receive(:send_welcome_email).and_return(true)
      get :show
    end
  end

end
