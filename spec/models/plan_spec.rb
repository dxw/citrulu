# encoding: utf-8
require 'spec_helper'

describe Plan do
  describe "print_cost" do
    it "should return a formatted string" do
      FactoryGirl.create(:plan, cost_gbp: 2323.0).print_cost.should == "£2323"
    end
  end
  
  describe "cost" do
    it "should return cost_gbp" do
      FactoryGirl.create(:plan, cost_gbp: 2323.0).cost.should == 2323.0
    end
  end
  
  describe ".cheapest active plan" do
    before(:all) do
      Plan.destroy_all
    end
    before(:each) do
      FactoryGirl.create(:plan, active: false)
    end
    it "should return nil when there are no active plans" do
      Plan.cheapest_active_plan.should be_nil
    end
    context "when there is one active plan" do
      it "should return that plan" do
        plan = FactoryGirl.create(:active_plan)
        Plan.cheapest_active_plan.should == plan
      end
    end
    context "when there are several active plans" do
      it "should return the cheapest" do
        FactoryGirl.create(:active_plan, cost_gbp: 2)
        plan = FactoryGirl.create(:active_plan, cost_gbp: 1)
        FactoryGirl.create(:active_plan, cost_gbp: 3)
        Plan.cheapest_active_plan.should == plan
      end
    end
  end
  
  describe ".default" do
    before(:all) do
      Plan.destroy_all
    end
    context "when there is one active default plan" do
      before(:each) do
        @plan = FactoryGirl.create(:plan, default: true, active: true)
      end
      it "should return that plan" do
        Plan.default.should == @plan
      end
    end
    context "when there is no active default plan" do
      context "but there is a cheapest active plan" do
        before(:each) do
          @plan = FactoryGirl.create(:plan)
          Plan.stub(:cheapest_active_plan).and_return @plan
        end
        it "should return that plan" do
          Plan.default.should == @plan
        end
        it "should raise an error in the log" do
          Rails.logger.should_receive(:error)
          Plan.default
        end
      end
      context "and there are no active plans" do
        before(:each) do
          Plan.stub(:cheapest_active_plan).and_return nil
        end
        it "should raise an error" do
          expect{ Plan.default }.to raise_error
        end
        
      end
    end
  end
  

  describe ".get_plan_name_from_plan_level" do
    it "should return the correct plan name" do
      stub_const("Plan::LEVELS", { :foo => "Bar" })
      Plan.get_plan_name_from_plan_level("foo").should == "Bar"
    end
  end
  describe ".get_plan_from_level" do
    it "should retrieve the named plan" do
      Plan.stub(:get_plan_name_from_plan_level).and_return("Baz")
      bar = FactoryGirl.create(:active_plan, name_en: "Baz")
      Plan.get_plan_from_level(:faz).should == bar
    end
  end
  describe ".get_spreedly_plan" do
    it "should_not_return a plan if it is not enabled" do
      splan = double("RSpreedly::SubscriptionPlan")
      splan.stub(:name).and_return("baz")
      splan.stub(:enabled).and_return false
    
      Plan.get_spreedly_plan([splan], "baz").should be_nil
    end
    it "should return the specified plan" do
      splan1 = double("RSpreedly::SubscriptionPlan")
      splan1.stub(:name).and_return("foo")
      splan1.stub(:enabled).and_return true
      
      splan2 = double("RSpreedly::SubscriptionPlan")
      splan2.stub(:name).and_return("bar")
      splan2.stub(:enabled).and_return true
      
      spreedly_plans = [splan1, splan2]
      
      Plan.get_spreedly_plan(spreedly_plans, "foo").should == splan1
      Plan.get_spreedly_plan(spreedly_plans, "bar").should == splan2
      
    end
  end
  
  describe ".cornichon" do
    it "should return a plan" do
      plan = FactoryGirl.create(:plan, :name_en => "Cornichon", :active => true)
      Plan.cornichon.should == plan
    end
    it "should return the most recent active plan with that name"
  end
  describe ".gherkin" do
    it "should return a plan" do
      plan = FactoryGirl.create(:plan, :name_en => "Gherkin", :active => true)
      Plan.gherkin.should == plan
    end
    it "should return the most recent active plan with that name"
  end
  describe ".cucumber" do
    it "should return a plan" do
      plan = FactoryGirl.create(:plan, :name_en => "Cucumber", :active => true)
      Plan.cucumber.should == plan
    end
    it "should return the most recent active plan with that name"
  end
  
  describe ".spreedly_plans" do
    it "should fetch plans from spreedly" do
      RSpreedly::SubscriptionPlan.stub(:all)
      RSpreedly::SubscriptionPlan.should_receive(:all)
      Plan.spreedly_plans
    end
  end
end
