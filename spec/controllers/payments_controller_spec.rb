require 'spec_helper'

describe PaymentsController do
  login_user

  describe "GET 'choose_plan'" do
    it "returns http success" do
      get 'choose_plan'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    context "with no plan ID" do
      it "should redirect to the plans page" do
        get 'new'
        response.should redirect_to('/payments/choose_plan')
      end
    end
    
    context "with a plan ID" do
      it "returns http success" do
        get 'new', :plan_id => 1
        response.should be_success
      end
    end
  end

  describe "GET 'confirmation'" do    
    it "returns http success" do
      get 'confirmation'
      response.should be_success
    end
  end

end