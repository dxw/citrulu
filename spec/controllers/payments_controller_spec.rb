require 'spec_helper'

describe PaymentsController do
  login_user
  
  describe "GET 'change_plan'" do
    
    context "with no plan ID" do
      it "should redirect to the plans page" do
        put 'change_plan'
        response.should redirect_to('/payments/choose_plan')
      end
    end
  
    context "with a plan ID" do
      before(:each) do
        @plan = FactoryGirl.create(:plan)
        User.any_instance.stub(:change_plan)
      end
      
      context "when the user is active in spreedly" do
        it "returns http success" do
          User.any_instance.stub(:status).and_return(:paid)
          put 'change_plan', :plan_id => @plan.to_param
          response.should redirect_to("/payments/change_plan_confirmation")
        end
      end
      
      context "when the user is inactive in spreedly" do
        it "should redirect to the homepage" do
          User.any_instance.stub(:status).and_return(:inactive)
          put 'change_plan', :plan_id => @plan.to_param
          response.should redirect_to('/')
        end
      end
    end
  end

  describe "GET 'new'" do
    context "when the user is active in spreedly" do
      it "should redirect to the homepage" do
        User.any_instance.stub(:status).and_return(:paid)
        get 'new'
        response.should redirect_to('/')
      end
    end
      
    context "when the user is inactive in spreedly" do
      before(:each) do
        User.any_instance.stub(:status).and_return(:inactive)
      end
      
      context "with no plan ID" do
        it "should redirect to the plans page" do
          get 'new'
          response.should redirect_to('/payments/choose_plan')
        end
      end
    
      context "with a plan ID" do
        it "should set @plan to the chosen plan" do
          plan = FactoryGirl.create(:plan)
          get 'new', :plan_id => plan.id
          response.should be_success
          assigns(:plan).should == plan
        end
      end
    end
  end

  describe "GET 'confirmation'" do 
    context "when the user is active in spreedly" do
      before(:each) do
        User.any_instance.stub(:status).and_return(:paid)
      end
      # nothing required at the moment...
    end
  end

end