require 'spec_helper'

describe TestGroup do
  before(:all) do
    @test_group_no_failures = FactoryGirl.create(:test_group, :successful_results => 2, :failed_results => 0)
    @test_group_2_failures = FactoryGirl.create(:test_group, :successful_results => 1, :failed_results => 2)
  end
  
  describe "number_of_failures" do
    it "should return 0 if there are no failures" do
      @test_group_no_failures.number_of_failures.should == 0
    end
    
    it "should return 2 if there are 2 failures and 1 success" do
      @test_group_2_failures.number_of_failures.should == 2
    end
  end
  
  describe "has_failures?" do
    it "should return false if there are no failures" do
      @test_group_no_failures.has_failures?.should == false
    end
    
    it "should return true if there are 2 failures and 1 success" do
      @test_group_2_failures.has_failures?.should == true
    end
  end
end
