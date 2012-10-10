require 'spec_helper'

describe User do
  before(:each) do
    @plan = FactoryGirl.create(:plan, test_frequency: 23)
    @user = FactoryGirl.create(:user)
    @user.update_attribute(:plan, @plan)
    
    @subscriber = double(RSpreedly::Subscriber)
    RSpreedly::Subscriber.stub(:new).and_return(@subscriber)
    RSpreedly::Subscriber.stub(:find) # By default, return nil (not found)
    RSpreedly::Subscriber.any_instance.stub(:update)
  end
  
  context "when it is created"
    it "should add the tutorial test files" do
      user = FactoryGirl.create(:user_with_tutorials)
      user.test_files.last.test_file_text.should == TUTORIAL_TEST_FILES.first[:text]
    end
    it "should set the email preference to recieve test run emails" do
      @user.email_preference.should == 1
    end
    it "should assign the default plan" do
      Plan.stub(:default).and_return(@plan)
      user = FactoryGirl.create(:user)
      user.plan.should == @plan
    end
  
  describe ".send_welcome_email" do
    it "should create a welcome email for the current user and deliver it" do
      UserMailer.should_receive(:welcome_email).with(@user).and_return(Mail::Message.new)
      Mail::Message.any_instance.should_receive(:deliver)
    
      @user.send_welcome_email
    end
  end
  
  it "should delete dependent test files when it is deleted" do
    #OK, so this is kind of testing ActiveRecord, but this is a fairly critical thing to happen:
    test_file_id = FactoryGirl.create(:test_file, :user => @user).id
    
    TestFile.find(test_file_id).user.should === @user
    
    RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
    @subscriber.stub(:stop_auto_renew)
    
    @user.destroy
    expect{ TestFile.find(test_file_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
  
  context "when dealing with Spreedly" do
    before(:each) do
      @plan = FactoryGirl.create(:plan)
      @user.confirm!
      @user.plan = @plan  
      @user.save!
    end
    
    describe "create_subscriber" do
      it "should create a subscriber record on spreedly" do
        RSpreedly::Subscriber.should_receive(:new)
        @subscriber.should_receive(:save!)
        @user.create_subscriber
      end
    end

    
    describe "update_subscriber" do
      before(:each) do
        RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
        
      end
      
      context "when there have been changes to the user" do
        it "should update the Spreedly subscriber" do
          @subscriber.should_receive(:update_attributes)
          
          @subscriber.stub(:respond_to?).and_return(true)
          @subscriber.stub(:send)
          
          @user.email = "faz@baz.com"
          @user.send(:update_subscriber)
        end
      end
      context "when there have NOT been changes to the user" do
        it "should not update the Spreedly subscriber" do
          @subscriber.should_not_receive(:update_attributes)
          @user.send(:update_subscriber)
        end
      end
    end
  
    describe "callbacks" do
      it "should destroy the subscription when the model is destroyed" do
        RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
        @subscriber.should_receive(:stop_auto_renew)
        @user.destroy
      end
      
      it "should do nothing if the model was destroyed but there is no subscriber" do
        RSpreedly::Subscriber.stub(:find).and_return(nil)
        RSpreedly::Subscriber.any_instance.should_not_receive(:destroy)
        RSpreedly::Subscriber.any_instance.should_not_receive(:stop_auto_renew)
        @user.destroy
      end
    end
  end
  
  describe "change_plan" do
    context "when the spreedly subscriber could be updated" do
      before(:each) do
        RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
        @subscriber.stub(:change_subscription_plan).and_return(true)
        @new_plan = FactoryGirl.create(:plan)
      end
      it "should update the frequencies of all the test_files" do
        @user.should_receive(:update_test_file_frequencies)
        @user.change_plan(@new_plan.id)
      end
    end
  end
  
  
  context "when calculating free trial periods" do
    describe ".is_within_free_trial" do
      before(:all) do
        @free_trial_days = 30 #doesn't seem to get pulled from config...
      end
      before(:each) do
        @user.confirm!
      end
      it "should return true if the user is active and was created less than x days ago" do
        pending "enforcement of trial periods" 
        
        Timecop.travel(Time.now + (@free_trial_days -1).days)
        @user.status = :free
        @user.is_within_free_trial?.should be_true
        
        Timecop.return() # So that the test running time metrics are accurate
      end
    
      it "should return false if the user is active and was created MORE than x days ago" do
        pending "enforcement of trial periods" 
        
        Timecop.travel(Time.now + (@free_trial_days +1).days)
        @user.status = :free
        @user.is_within_free_trial?.should be_false
        
        Timecop.return() # So that the test running time metrics are accurate
      end
    end
  end
  
  describe "new_test_file_name" do
    it "should return 'New test file' if there are no other test files" do
      @user.new_test_file_name.should == 'New test file'
    end
    
    context "if 'New test file' exists" do
      before(:each) do
        FactoryGirl.create(:test_file, user: @user, name: 'New test file')
      end
    
      it "should return 'New test file 1'" do
        @user.new_test_file_name.should == 'New test file 1'
      end
      
      context "and if a test file exists with a different name" do
        before(:each) do
          FactoryGirl.create(:test_file, user: @user, name: 'Foo')
        end
      
        it "should return 'New test file 1'" do
          @user.new_test_file_name.should == 'New test file 1'
        end
      end
      
      context "and if 'New test file 1' exists" do
        before(:each) do
          FactoryGirl.create(:test_file, user: @user, name: 'New test file 1')
        end
      
        it "should return 'New test file 2'" do
          @user.new_test_file_name.should == 'New test file 2'
        end
      end
    end
  end
  
  describe "create_tutorial_test_files" do
    it "should execute without errors" do
      expect { @user.create_tutorial_test_files }.to_not raise_error
    end
  end
  
  describe "first_tutorial" do
    before(:each) do
      @new_user = FactoryGirl.create(:user)
      @new_user.test_files.destroy_all
      FactoryGirl.create(:test_file, user: @new_user, tutorial_id: 2)
    end
    it "should return nil if the appropriate test file doesn't exist" do
      @new_user.first_tutorial.should be_nil
    end
    
    it "should return the test file associated with the current user which has a tutorial ID of 1" do
      tutorial_file = FactoryGirl.create(:test_file, user: @new_user, tutorial_id: 1)
      @new_user.first_tutorial.should == tutorial_file
    end
    
    it "should not return the test file associated with the current user which has a tutorial ID of 1 if that file is deleted" do
      tutorial_file = FactoryGirl.create(:test_file, user: @new_user, tutorial_id: 1, deleted: true)
      @new_user.first_tutorial.should be_nil
    end
    
  end
  
  describe "create_new_test_file" do
    before(:each) do      
      @count = @user.test_files.count
      @user.create_new_test_file
      @new_test_file = @user.test_files.last
    end
    
    it "should create an empty test_file" do
      @user.test_files.count.should == @count + 1
      @new_test_file.test_file_text.should be_blank
    end
    
    it "should be set to run tests " do
      @new_test_file.run_tests.should be_true
    end
    
    it "should set the frequency based on the user's current plan" do
      #N.B. this will change in future if we allow frequency to be set on a per-file basis
      @new_test_file.frequency.should == 23
    end
  end
  
  describe "create_first_test_file" do
    before(:each) do      
      @count = @user.test_files.count
      @user.create_first_test_file
      @new_test_file = @user.test_files.last
    end
    
    it "should create a test_file with helpful text in it" do
      @user.test_files.count.should == @count + 1
      @new_test_file.test_file_text.should == FIRST_TEST_FILE_TEXT
    end
    
    it "should be set to run tests " do
      @new_test_file.run_tests.should be_true
    end
    
    it "should set the frequency based on the user's current plan" do
      #N.B. this will change in future if we allow frequency to be set on a per-file basis
      @new_test_file.frequency.should == 23
    end
  end
  
  
  describe "number_of_domains" do
    # TODO: I think the best practice way to test this is to mock out the test files such that the domains lists can be stubbed... 
    
    it "should return 0 if the user has no test files" do
      # Double check that the user has no test files
      @user.test_files.not_tutorial.length.should == 0

      @user.number_of_domains.should == 0
    end
    it "should return 0 if the user has no compiled test files" do
      text = nil
      FactoryGirl.create(:test_file, user: @user, domains: nil, compiled_test_file_text: "foo")
      @user.number_of_domains.should == 0
    end
    it "should return 1 if the user has 1 compiled test file containing 1 domain" do
      FactoryGirl.create(:test_file, user: @user, domains: ["abc.com"], compiled_test_file_text: "foo")
      @user.number_of_domains.should == 1
    end
    it "should return 2 if the user has 1 compiled test file containing 2 domains" do
      FactoryGirl.create(:test_file, user: @user, domains: ["abc.com","xyz.com"], compiled_test_file_text: "foo")
      @user.number_of_domains.should == 2
    end
    it "should return 2 if the user has 2 compiled test files, each containing 1 domain" do
      FactoryGirl.create(:test_file, user: @user, domains: ["abc.com"], compiled_test_file_text: "foo")
      FactoryGirl.create(:test_file, user: @user, domains: ["xyz.com"], compiled_test_file_text: "foo")
      @user.number_of_domains.should == 2
    end
    it "should return 1 if the user has 2 compiled test files, each containing the same 1 domain" do
      FactoryGirl.create(:test_file, user: @user, domains: ["abc.com"], compiled_test_file_text: "foo")
      FactoryGirl.create(:test_file, user: @user, domains: ["abc.com"], compiled_test_file_text: "foo")
      @user.number_of_domains.should == 1
    end
  end
  
  describe "(stats)" do
    describe "pages_average_times_in_past_week" do 
      before(:each) do
        # The test files linked to the user are v. important, so create a fresh user record, just in case.
        @user = FactoryGirl.create(:user)
        @test_file = FactoryGirl.create(:test_file, user: @user)
        @test_run = FactoryGirl.create(:test_run, test_file: @test_file)
      end
      it "should return nil when there are no test groups" do
        @user.pages_average_times_in_past_week.should == {}
      end
      context "when there is one test group" do
        before(:each) do
          response = FactoryGirl.create(:response, response_time: 23)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response, test_url: "http://www.google.com" )
        end
        it "should return the response_time for that group" do
          @user.pages_average_times_in_past_week.should == { "http://www.google.com" => 23}
        end
      end  
      context "when there are two test groups with different urls" do
        before(:each) do
          response1 = FactoryGirl.create(:response, response_time: 17)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.google.com" )
          response2 = FactoryGirl.create(:response, response_time: 23)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.amazon.co.uk" )
        end
        it "should return the response times for both groups" do
          @user.pages_average_times_in_past_week.should == { "http://www.google.com" => 17, "http://www.amazon.co.uk" => 23 }
        end
      end
      context "when there are two test groups with the same url and different response_times" do
        before(:each) do
          response1 = FactoryGirl.create(:response, response_time: 17)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.google.com" )
          response2 = FactoryGirl.create(:response, response_time: 23)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.google.com" )
        end
        it "should return the response times for both groups" do
          @user.pages_average_times_in_past_week.should == { "http://www.google.com" => 20 }
        end
      end
      context "when there are three test groups with different urls from the same domain" do
        before(:each) do
          response1 = FactoryGirl.create(:response, response_time: 17)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.google.com" )
          response2 = FactoryGirl.create(:response, response_time: 23)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.google.com/foo" )          
          response2 =  FactoryGirl.create(:response, response_time: 11)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "http://www.google.com?search=bar" )
        end
        it "should treat all the urls individually" do
          @user.pages_average_times_in_past_week.should == {  "http://www.google.com" => 17, 
                                                              "http://www.google.com/foo" => 23, 
                                                              "http://www.google.com?search=bar" => 11 }
        end
      end
      context "where there are a number of test groups from different test runs with some overlap" do
        before(:each) do
          test_run2 = FactoryGirl.create(:test_run, test_file: @test_file)
          
          response1 = FactoryGirl.create(:response, response_time: 11)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response1, test_url: "http://www.google.com" )
          response2 = FactoryGirl.create(:response, response_time: 23)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response2, test_url: "https://citrulu.com" )
          
          response3 = FactoryGirl.create(:response, response_time: 18)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response3, test_url: "http://www.swingoutlondon.co.uk" )
          response4 = FactoryGirl.create(:response, response_time: 14)
          FactoryGirl.create(:test_group, test_run: @test_run, response: response4, test_url: "http://www.google.com" )
        end
        it "should return the average response times for overlapping urls" do
          @user.pages_average_times_in_past_week.should == {  "http://www.google.com" => 12.5, 
                                                              "https://citrulu.com" => 23, 
                                                              "http://www.swingoutlondon.co.uk" => 18 }
        end
      end
    end
    
    describe "groups_with_failures_in_past_week" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @test_file = FactoryGirl.create(:test_file, user: @user)
        @test_run = FactoryGirl.create(:test_run, test_file: @test_file)
      end
      it "should return [] if there are no test groups" do
        @user.groups_with_failures_in_past_week.should == []
      end
      it "should return [] if there is a test_group with no failures" do
        FactoryGirl.create(:test_group_no_failures, test_run: @test_run )
        @user.groups_with_failures_in_past_week.should == []
      end
      context "when there is one test group with failures" do
        before(:each) do
          @test_group = FactoryGirl.create(:test_group_with_failures, test_run: @test_run)
        end
        it "should return that test group" do
          @user.groups_with_failures_in_past_week.should == [@test_group]
        end
      end
      it "should return the sum of all failed test groups from the past week" do
        test_run1 = FactoryGirl.create(:test_run, test_file: @test_file)
        
        @test_group1 = FactoryGirl.create(:test_group_with_failures, test_run: @test_run)
        @test_group2 = FactoryGirl.create(:test_group_with_failures, test_run: @test_run) 
        @test_group3 = FactoryGirl.create(:test_group_with_failures, test_run: test_run1) 
        
        @user.groups_with_failures_in_past_week.should == [@test_group1, @test_group2, @test_group3]
      end
    end

    describe "enqueue_stats_email" do
      before(:each) do
        # We don't actually want to enqueue stuff:
        Resque.stub(:enqueue)
      end
      it "should call enqueue on Resque with the stats job" do
        Resque.should_receive(:enqueue).with(TestFileJob, anything())
        @user.enqueue_stats_email
      end
      it "should call enqueue on Resque with the current user's ID" do
        Resque.should_receive(:enqueue).with(anything(), @user.id)
        @user.enqueue_stats_email
      end
    end
    
    describe ".enqueue_all_stats_emails" do
      before(:each) do
        # We don't actually want to enqueue stuff:
        Resque.stub(:enqueue)
        User.destroy_all
      end
      it "should do nothing if there is only one user, and that user has chosen not to receive emails" do
        @user_no_notify = FactoryGirl.create(:user, email_preference: 0)
        User.any_instance.should_not_receive(:enqueue_stats_email)
        User.enqueue_all_stats_emails
      end
      it "if there is only one user, and that user has chosen to receive emails, it should enqueue an email for that user" do
        @user_notify = FactoryGirl.create(:user, email_preference: 1)
        User.any_instance.should_receive(:enqueue_stats_email).once
        User.enqueue_all_stats_emails
      end  
    end
  end
  
end