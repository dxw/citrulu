require 'spec_helper'

describe ConfirmationsController do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "show" do
    
    it "Sends a welcome email to logged in users" do
      @user = Factory.create(:confirmed_user)
      User.stub(:confirm_by_token).and_return(@user)

      @user.should_receive(:send_welcome_email)
      
      get :show, :confirmation_token => "foo"   
    end
  end

end
