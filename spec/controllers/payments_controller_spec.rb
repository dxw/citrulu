require 'spec_helper'

describe PaymentsController do
  login_user
  
  before(:each) do
    @subscriber = double(RSpreedly::Subscriber)
    User.any_instance.stub(:subscriber).and_return(@subscriber)
  end

  describe "GET 'choose_plan'" do
    context "when the user is active in spreedly" do
      it "should redirect to the homepage" do
        @subscriber.stub(:active).and_return(true)
        get 'choose_plan'
        response.should redirect_to('/')
      end
    end
      
    context "when the user is inactive in spreedly" do
      it "returns http success" do
        @subscriber.stub(:active).and_return(false)
        get 'choose_plan'
        response.should be_success
      end
    end
  end

  describe "GET 'new'" do
    context "when the user is active in spreedly" do
      it "should redirect to the homepage" do
        @subscriber.stub(:active).and_return(true)
        get 'new'
        response.should redirect_to('/')
      end
    end
      
    context "when the user is inactive in spreedly" do
      before(:each) do
        @subscriber.stub(:active).and_return(false)
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
        @subscriber.stub(:active).and_return(true)
      end
      it "sets @plan to the user's plan" do
        plan = FactoryGirl.create(:plan)
        @user.plan = plan
        @user.save!
        get 'confirmation'

        assigns(:plan).should == plan
      end
       
      it "sets @test files to the user's test_files" do
        get 'confirmation'
        assigns(:test_files).should == @user.test_files
      end
    end
  end

end