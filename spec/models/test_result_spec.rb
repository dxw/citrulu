require 'spec_helper'

describe TestResult do
  describe "failed" do
    it "should return true if the test failed" do
      test_run = FactoryGirl.build(:test_result, :result => false)

      test_run.failed?.should == true
    end

    it "should return false if the test passed" do
      test_run = FactoryGirl.build(:test_result, :result => true)

      test_run.failed?.should == false
    end
  end
end
