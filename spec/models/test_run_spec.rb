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


  context "when there are no failed groups and no failed tests" do
    before(:each) do
      @test_run_success = FactoryGirl.create(:test_run_no_failures)
    end
    
    describe "has_failures?" do
      it "should return false" do
        @test_run_success.has_failures?.should be_false
      end
    end
    
    describe "has_failed_groups?" do
      it "should return true" do
        @test_run_success.has_failed_groups?.should be_false
      end
    end
    
    describe "failed_groups" do
      it "should return the empty array" do
        @test_run_success.failed_groups.should == []
      end
    end
    
    describe "number_of_failed_tests" do
      it "should be 0" do
        @test_run_success.number_of_failed_tests.should== 0
      end
    end
    
    describe "has_groups_with_failed_tests?" do
      it "should return false" do
        @test_run_success.has_groups_with_failed_tests?.should be_false
      end
    end
    
    describe "groups_with_failed_tests" do
      it "should return the empty array" do
        @test_run_success.groups_with_failed_tests.should == []
      end
    end
    
    describe "number_of_failing_groups" do
      it "should return 0" do
        @test_run_success.number_of_failing_groups.should == 0
      end
    end
    
    describe "groups_with_failures" do
      it "should return the empty array" do
        @test_run_success.groups_with_failures.should == []
      end
    end
    
  end
  
  
  context "when there is 1 failed group and no failed tests" do
    before(:each) do
      @test_run2 = FactoryGirl.create(:test_run_no_failures) # creates 2 test groups
      @test_group = FactoryGirl.create(:test_group_no_failures, :message => "I failed innit", :test_run => @test_run2) 
    end
    
    describe "has_failures?" do
      it "should return true" do
        @test_run2.has_failures?.should be_true
      end
    end
    
    describe "has_failed_groups?" do
      it "should return true" do
        @test_run2.has_failed_groups?.should be_true
      end
    end
    
    describe "failed_groups" do
      it "should return one test group"
    end
    
    describe "number_of_failed_tests" do
      it "should be 0" do
        @test_run2.number_of_failed_tests.should== 0
      end
    end 
    
    describe "has_groups_with_failed_tests?" do
      it "should return false" do
        @test_run2.has_groups_with_failed_tests?.should be_false
      end
    end
    
    describe "groups_with_failed_tests" do
      it "should return the empty array" do
        @test_run2.groups_with_failed_tests.should == []
      end
    end
    
    describe "number_of_failing_groups" do
      it "should return 1" do
        @test_run2.number_of_failing_groups.should == 1
      end
    end
    
    describe "groups_with_failures" do
      it "should return one test group"
    end
    
  end
  
  context "when there are no failed groups and 2 failed tests" do
    describe "has_failures?" do
      it "should return true" do
        @test_run.has_failures?.should be_true
      end
    end
    
    describe "has_failed_groups?" do
      it "should return true" do
        @test_run.has_failed_groups?.should be_false
      end
    end
    
    describe "failed_groups" do
      it "should return the empty array" do
        @test_run.failed_groups.should == []
      end
    end
    
    describe "number_of_failed_tests" do
      it "should be 2" do
        @test_run.number_of_failed_tests.should== 2
      end
    end 
    
    describe "has_groups_with_failed_tests?" do
      it "should return true" do
        @test_run.has_groups_with_failed_tests?.should be_true
      end
    end
    
    describe "groups_with_failed_tests" do
      it "should return an array of two test groups"
    end
    
    describe "number_of_failing_groups" do
      it "should return 2" do
        @test_run.number_of_failing_groups.should == 2
      end
    end
    
    describe "groups_with_failures" do
      it "should return two test_groups"
    end
  end

end