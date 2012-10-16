require 'spec_helper'

describe RegistrationsController do
  login_user
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  describe "POST create" do
    before(:each) do
      User.any_instance.stub(:active_for_authentication?).and_return false # At the moment we always require users to confirm before logging in
    end
    context "when the record is successfully saved" do
      before(:each) do
        User.any_instance.stub(:save).and_return true
      end
      it "should redirect to the sign in path" do
        post :create
        response.should redirect_to(controller: "sessions", action: "new")
      end
      it "should log an event" do
        pending "These tests don't actually seem to be calling the def.n in registrations_controller.rb"
        controller.should_receive(:log_event)
        post :create
      end
    end
    context "when the record is not successfully saved" do
      before(:each) do
        User.any_instance.stub(:save).and_return false
      end
      it "should render the homepage " do
        post :create
        response.should render_template(action: "new")
      end
    end
  
  end
  
  describe "PUT update" do
    login_user
    
    it "should require the current password for updating the email" do
      put :update, user: { email: "new_email@foobar.com" }
      flash[:notice].should be_nil
      response.should render_template(:controller => "registrations", :action => "edit")
    end
    it "should update the email if current_password is provided" do
      put :update, user: { email: "new_email@foobar.com", current_password: @user.password }
      flash[:notice].should_not be_nil
      response.should redirect_to(:controller => "registrations", :action => "edit")
    end
    
    context "when validation fails" do
      before(:each) do
        User.any_instance.stub(:update_with_password).and_return(false)
        User.any_instance.stub(:update_attributes).and_return(false)
      end
      it "should render the edit view" do
        User.any_instance.stub(:unconfirmed_email)
        controller.stub(:clean_up_passwords)
 
        put :update
        response.should render_template(:controller => "registrations", :action => "edit")
      end
    end
    
    context "when the update is successful" do
      it "should redirect to edit" do
        User.any_instance.stub(:update_with_password).and_return(true)
        put :update
        response.should redirect_to(:controller => "registrations", :action => "edit")
      end
      
      it "updates the current user's email preference if they changed it" do
        # N.B. This is not a great way of writing tests - this is more like a request spec, but it's an important bit to check.
        @user.email_preference = 1
        User.find(@user.id).email_preference.should == 1
        put :update, user: { current_password: @user.password, email_preference: 0 }
        User.find(@user.id).email_preference.should == 0
      end
    end
  end

end