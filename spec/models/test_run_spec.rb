require 'spec_helper'

describe TestRun do
  before(:each) do
    @test_run = FactoryGirl.create(:test_run)
    test_group_1 = FactoryGirl.create(:test_group, :test_run => @test_run)
    test_group_2 = FactoryGirl.create(:test_group, :test_run => @test_run)
    FactoryGirl.create(:test_result, :test_group => test_group_1, :result => false)
    FactoryGirl.create(:test_result, :test_group => test_group_2, :result => false)
    FactoryGirl.create(:test_result, :test_group => test_group_2, :result => true)
  end

  describe "number_of_pages" do
    it "should return the number of test groups in the run" do
      @test_run.number_of_pages.should == 2
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
end
