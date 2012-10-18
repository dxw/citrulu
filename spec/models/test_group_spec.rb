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
  
  describe ".failed_groups_reasons" do
    it "should return nil when there are no failed groups" do
      TestGroup.failed_groups_reasons.should be_nil
    end
    it "should return a single result if there is only one failed group" do
      group = FactoryGirl.create(:test_group_no_results, message: "foo" )
      TestGroup.failed_groups_reasons.should == { 'foo' => 1 } 
    end
    it "should return two results if there are two failed groups with different messages" do
      FactoryGirl.create(:test_group_no_results, message: "foo" )
      FactoryGirl.create(:test_group_no_results, message: "bar" )
      TestGroup.failed_groups_reasons.should == { 'foo' => 1, 'bar' => 1,  } 
    end
    it "should return a single result if there are two failed groups with the same messages" do
      FactoryGirl.create(:test_group_no_results, message: "foo" )
      FactoryGirl.create(:test_group_no_results, message: "foo" )
      TestGroup.failed_groups_reasons.should == { 'foo' => 2 } 
    end
  end
  
  describe "failed_tests" do
    it "should return the empty array if there are no failures" do
      @test_group_no_failures.failed_tests.should be_empty
    end
    
    it "should contain 2 elements if there are 2 failures and 1 success" do
      @test_group_2_failures.failed_tests.length.should == 2
    end
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
