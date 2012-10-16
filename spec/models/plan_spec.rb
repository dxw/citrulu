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
