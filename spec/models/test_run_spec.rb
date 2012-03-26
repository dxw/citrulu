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

  describe "number_of_checks" do
    it "should return the total number of checks in all its groups" do
      @test_run.number_of_checks.should== 3
    end
  end

  describe "number_of_failures" do
    it "should return the total failures in all its groups" do
      @test_run.number_of_failures.should== 2
    end
  end
  
  describe "has_failures?" do
    it "should return false if there are no failures" do
      FactoryGirl.create(:test_run_no_failures).has_failures?.should == false
    end
    
    it "should return true if there are failures" do
      @test_run.has_failures?.should == true
    end
  end
end
