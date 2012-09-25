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
  
  describe "name" do
    it "should return the correct string" do
      time_run = "2012-05-30 11:44:20 +0100".to_time
      test_file = FactoryGirl.create(:test_file, name: "My Test File")
      test_run = FactoryGirl.create(:test_run, test_file: test_file, time_run: time_run)
      
      test_run.name.should == "My Test File::2012-05-30 10:44:20 UTC"
    end
  end
  
  describe "previous_run" do
    before(:each) do
      @test_file = FactoryGirl.create(:test_file)
      @test_run0 = FactoryGirl.create(:test_run, :time_run => (Time.now - 10), :test_file => @test_file)
      @test_run1 = FactoryGirl.create(:test_run, :time_run => (Time.now - 5), :test_file => @test_file)
      @test_run2 = FactoryGirl.create(:test_run, :time_run => Time.now, :test_file => @test_file)
    end
    
    it "should return nil if there are no previous test runs" do
      @test_run0.previous_run.should be_nil
    end
  
    it "should return the previous test run if the test run is the latest" do
      @test_run2.previous_run.should === @test_run1
    end

    it "should return the previous test run if the test run is not the latest" do
      @test_run1.previous_run.should === @test_run0
    end
  end
  
  
  describe "users_first_run?" do
    before(:each) do
      @user1 = FactoryGirl.create(:user)
      @test_fileA = FactoryGirl.create(:test_file, user: @user1)
      @test_runA = FactoryGirl.create(:test_run, test_file: @test_fileA)
    end
    
    it "should return false if there are two test runs for the same test_file" do
      FactoryGirl.create(:test_run, test_file: @test_fileA)

      @test_runA.users_first_run?.should be_false
    end
    
    it "should return false if there is a run for the same user in a different test_file" do
      test_fileB = FactoryGirl.create(:test_file, user: @user1)
      FactoryGirl.create(:test_run, test_file: test_fileB)
      
      @test_runA.users_first_run?.should be_false
    end
    
    it "should return true if the only other Run is for a different user" do
      user2 = FactoryGirl.create(:user)
      test_fileC = FactoryGirl.create(:test_file, user: user2)
      FactoryGirl.create(:test_run, test_file: test_fileC)      

      @test_runA.users_first_run?.should be_true
    end
    
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
  
  describe "delete_all_older_than" do
    before(:each) do
      TestRun.destroy_all
      @time = Time.now
      FactoryGirl.create(:test_run, time_run: @time - 1.day)
      @test_run_1 = FactoryGirl.create(:test_run, time_run: @time)
      @test_run_2 = FactoryGirl.create(:test_run, time_run: @time + 1.day)
    end
    it "should delete test_runs older than the specified time" do
      TestRun.delete_all_older_than(@time)
      TestRun.all.length.should
      TestRun.all.should include(@test_run_1)
      TestRun.all.should include(@test_run_2)
    end
  end
  
  describe "(stats)" do
    describe "pages_average_times" do
      before(:each) do
        @test_run = FactoryGirl.create(:test_run)
      end
      context "when there is one url with no response" do
        before(:each) do
          # e.g. because the page couldn't be retrieved
          FactoryGirl.create(:test_group, test_run: @test_run, response: nil)
        end
        it "should return an empty hash" do
          @test_run.pages_average_times.should == {}
        end
      end
      context "when there is one url but no success response" do
        # We're only interested in 200 codes:
        before(:each) do
          response = FactoryGirl.create(:response, code: "404" )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response)
        end
        it "should return an empty hash" do
          @test_run.pages_average_times.should == {}
        end
      end
      context "when there is one url and a success response but no response_time" do
        before(:each) do
          response = FactoryGirl.create(:response, code: "200", response_time: nil )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response)
        end
        it "should raise an exception" do
          expect { @test_run.pages_average_times }.to raise_exception
        end
      end
      context "when there is one url and a success response" do
        before(:each) do
          response = FactoryGirl.create(:response, code: "200", response_time: 500 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response, test_url: "http://www.swingoutlondon.co.uk")
        end
        it "should return a hash" do
          @test_run.pages_average_times.should == { "http://www.swingoutlondon.co.uk" => 500 }
        end
      end
      context "when there are several (different) urls and with success responses" do
        before(:each) do
          response1 = FactoryGirl.create(:response, code: "200", response_time: 500 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.swingoutlondon.co.uk")
          response2 = FactoryGirl.create(:response, code: "200", response_time: 17 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.google.co.uk")
          response3 = FactoryGirl.create(:response, code: "200", response_time: 23 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response3, test_url: "http://www.amazon.co.uk")
        end
        it "should return a hash" do
          @test_run.pages_average_times.should == { "http://www.swingoutlondon.co.uk" => 500,
                                                    "http://www.google.co.uk" => 17,
                                                    "http://www.amazon.co.uk" => 23 }
        end
      end
      context "when there are two groups with the same url and success responses" do
        before(:each) do
          response1 = FactoryGirl.create(:response, code: "200", response_time: 33 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.google.co.uk")
          response2 = FactoryGirl.create(:response, code: "200", response_time: 17 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.google.co.uk")
        end
        it "should return a hash" do
          @test_run.pages_average_times.should == { "http://www.google.co.uk" => 25 }
        end
      end
      context "when there are multiple overlapping groups with success and failure responses" do
        before(:each) do
          response1 = FactoryGirl.create(:response, code: "200", response_time: 35 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.google.co.uk")
          response2 = FactoryGirl.create(:response, code: "200", response_time: 23 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.amazon.co.uk")
          response3 = FactoryGirl.create(:response, code: "200", response_time: 5 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response3, test_url: "http://www.google.co.uk")
          response4 = FactoryGirl.create(:response, code: "404", response_time: 17 )
          FactoryGirl.create(:test_group, test_run: @test_run, response: response4, test_url: "http://www.google.co.uk")
        end
        it "should return a hash" do
          @test_run.pages_average_times.should == { "http://www.google.co.uk" => 20 , "http://www.amazon.co.uk" => 23}
        end
      end
    end
  end
end
