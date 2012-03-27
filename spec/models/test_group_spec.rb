require 'spec_helper'

describe TestGroup do
  before(:each) do
    @test_group_no_failures = FactoryGirl.create(:test_group, :successful_results => 2, :failed_results => 0)
    @test_group_2_failures = FactoryGirl.create(:test_group, :successful_results => 1, :failed_results => 2)
  end
  
  it "should delete dependent test results when it is deleted" do
    # Approach: Pick the first test result and check that it gets deleted
    test_result_id = @test_group_no_failures.test_results.first
    
    @test_group_no_failures.destroy
    
    expect{ TestResult.find(test_result_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
  
  describe "number_of_failed_tests" do
    it "should return 0 if there are no failures" do
      @test_group_no_failures.number_of_failed_tests.should == 0
    end
    
    it "should return 2 if there are 2 failures and 1 success" do
      @test_group_2_failures.number_of_failed_tests.should == 2
    end
  end
  
  describe "failed?" do 
    it "should return false if the message on the group is empty" do
      @test_group_no_failures.message = ""
      @test_group_no_failures.failed?.should == false
    end
    
    it "should return false if the message on the group is nil" do
      @test_group_no_failures.message = nil
      @test_group_no_failures.failed?.should == false
    end
    
    it "should return true if the message on the group is not blank" do
      @test_group_no_failures.message = "foo"
      @test_group_no_failures.failed?.should == true
    end
  end
  
  describe "has_failed_tests?" do 
    it "should return false when there are no failed tests" do
      @test_group_no_failures.has_failed_tests?.should == false
    end
    
    it "should return true if there are 2 failed tests and 1 successful test" do
      @test_group_2_failures.has_failed_tests?.should == true
    end
  end
end
