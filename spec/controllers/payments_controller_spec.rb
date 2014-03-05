require 'spec_helper'

describe PaymentsController do
  login_user

  describe "GET 'choose_plan'" do
    before(:each) do
      Plan.stub(:limits).and_return([])
      Plan.stub(:features).and_return([])

      User.any_instance.stub(:status).and_return(:paid)

      get :choose_plan
    end
    it "should assign the plan names" do
      assigns[:names].should be_a(Hash)
    end
    it "should assign the plan limits" do
      assigns[:limits].should be_an(Array)
    end
    it "should assign the plan features" do
      assigns[:features].should be_an(Array)
    end
  end

  describe "PUT 'change_plan'" do

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
        User.any_instance.stub(:plan).and_return(FactoryGirl.create(:plan))
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
          response.should redirect_to('/payments/choose_plan')
        end
      end
    end
  end

  describe "GET 'new'" do
    context "when the user is active in spreedly" do
      it "should redirect to the homepage" do
        User.any_instance.stub(:status).and_return(:paid)
        get 'new'
        response.should redirect_to('/payments/choose_plan')
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

  describe "POST create" do
    before(:each) do
      User.any_instance.stub(:create_or_update_subscriber)
      User.any_instance.stub(:subscriber)

      @plan = FactoryGirl.create(:plan)
      Plan.any_instance.stub(:spreedly_id)
      Plan.stub(:find).and_return(@plan)

      @invoice = double('RSpreedly::Invoice')
      @invoice.stub(:save!)
      @invoice.stub(:pay)
      @invoice.stub(:errors)
      RSpreedly::Invoice.stub(:new).and_return(@invoice)

      @card = double('RSpreedly::PaymentMethod::CreditCard')

      RSpreedly::PaymentMethod::CreditCard.stub(:new).and_return(@card)
    end
    it "should assign @plan" do
      post :create, plan_id: @plan.to_param
      assigns[:plan].should == @plan
    end
    it "should assign @credit_card" do
      post :create, plan_id: @plan.to_param
      assigns[:credit_card].should == @card
    end
    context "when the invoice could be successfully paid" do
      before(:each) do
        @invoice.stub(:pay).and_return(true)
      end
      it "should assign the current user to the selected plan" do
        post :create, plan_id: @plan.to_param
        controller.current_user.plan.should == @plan
      end
      it "should set the current user's stats to :paid" do
        post :create, plan_id: @plan.to_param
        controller.current_user.status.should == :paid
      end
      it "should save the user" do
        controller.current_user.should_receive(:save!)
        post :create, plan_id: @plan.to_param
      end
    end

    context "when the invoice could not be paid" do
      before(:each) do
        @invoice.stub(:pay).and_return(false)
        @invoice.stub(:errors).and_return(["foo"])
        post :create, plan_id: @plan.to_param
      end
      it "should assign @errors" do
        assigns[:errors].should be_an(Array)
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