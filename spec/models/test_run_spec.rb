require 'spec_helper'

describe TestRun do
  before(:each) do    
    # Create a test run with a mixture of failures and successes
    @test_run = FactoryGirl.create(:test_run)
    @test_group_1 = FactoryGirl.create(:test_group, :successful_results => 0, :failed_results => 1, :test_run => @test_run)
    test_group_2 = FactoryGirl.create(:test_group, :successful_results => 1, :failed_results => 1, :test_run => @test_run)
  end
  
  it "should delete dependent test groups when it is deleted" do
    test_group_1_id = @test_group_1.id
    
    @test_run.destroy
    
    expect{ TestGroup.find(test_group_1_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe "number_of_pages" do
    it "should return the number of test groups in the run" do
      @test_run.number_of_pages.should == 2
    end
  end

  describe "owner" do
    it "should return the user that owns the test run" do
      user = FactoryGirl.create(:user)
      test_file = FactoryGirl.create(:test_file, :user => user)
      test_run = FactoryGirl.create(:test_run, :test_file => test_file)

      test_run.owner.should == user
    end
  end

  describe "number_of_tests" do
    it "should return the total number of checks in all its groups" do
      @test_run.number_of_tests.should== 3
    end
  end

  describe "number_of_failed_tests" do
    it "should return the total failures in all its groups" do
      @test_run.number_of_failed_tests.should== 2
    end
  end
  
  describe "has_failures?" do
    it "should return false if there are no failed tests" do
      FactoryGirl.create(:test_run_no_failures).has_failures?.should be_false
    end
    
    it "should return true if there are failed tests" do
      @test_run.has_failures?.should be_true
    end
    
    it "should return true if there are failed test groups"
  end
  
  describe "groups_with_failures" do
    it "should return the empty array if there are no failing groups"
    it "should return two elements if there are two failing groups"
  end
  
  describe "number_of_failing_groups" do
    it "should return 0 if there are no failing groups" do
      FactoryGirl.create(:test_run_no_failures).number_of_failing_groups.should == 0
    end
    
    it "should return 2 if there are two failing tests and no failing groups" do
      @test_run.number_of_failing_groups.should == 2
    end
    
    it "should return 1 if there is one failing group and no failing tests" do
      @clean_test_run = FactoryGirl.create(:test_run)
      test_group = FactoryGirl.create(:test_group_no_failures, :message => "I failed innit", :test_run => @clean_test_run)
      @clean_test_run.number_of_failing_groups.should == 1
    end
  end
  
  describe "has_failed_groups?" do
    before(:each) do
      @clean_test_run = FactoryGirl.create(:test_run)
    end
    
    it "should return false if there are groups with failed tests but no failed groups" do
      @test_run.has_failed_groups?.should be_false
    end 
      
    it "should return true if there are failed groups but no failed tests" do
      test_group = FactoryGirl.create(:test_group_no_failures, :message => "I failed innit", :test_run => @clean_test_run)
      @clean_test_run.has_failed_groups?.should be_true
    end
  end
  
  describe "has_groups_with_failed_tests?" do
    before(:each) do
      @clean_test_run = FactoryGirl.create(:test_run)
    end
    it "should return true if there are groups with failed tests but no failed groups" do
      @test_run.has_groups_with_failed_tests?.should be_true
    end
    
    it "should return false if there are failed groups but no failed test" do
      test_group = FactoryGirl.create(:test_group_no_failures, :message => "I failed innit", :test_run => @clean_test_run)
      @clean_test_run.has_groups_with_failed_tests?.should be_false
    end
  end
end