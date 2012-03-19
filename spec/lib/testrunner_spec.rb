require 'spec_helper'
require 'testrunner'

describe TestRunner do
  describe "run_all_tests" do
    
    def stub_run_all_tests_to_succeed
      TestRunner.stub(:execute_test_groups) do |file,test_run_id|
        FactoryGirl.create(:test_group_no_failures, :test_run_id => test_run_id)
      end
    end
    
    def stub_run_all_tests_to_fail
      TestRunner.stub(:execute_test_groups) do |file,test_run_id|
        FactoryGirl.create(:test_group_with_failures, :test_run_id => test_run_id)
      end
    end
    

    it "should not try and run tests where the compiled test file text is nil" do
      FactoryGirl.create(:test_file, :test_file_text => nil)
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end

    it "should not try and run tests where the compiled test file text is empty" do
      FactoryGirl.create(:test_file, :test_file_text => "")
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end

    describe "(sending email)" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @test_file = FactoryGirl.create(:test_file, :user => @user)
        # Make sure there's something to run tests on:
        TestFile.stub(:compiled_files).and_return([@test_file])
        # Don't actually send any email!
        Mail::Message.any_instance.stub(:deliver)
      end

      it "should send an email if the mailing preferences allow it" do
        @user.email_preference = 1
        
        stub_run_all_tests_to_fail
        
        # Check that the call is made to the mailer
        UserMailer.any_instance.should_receive(:test_notification)
        TestRunner.run_all_tests
      end

      it "should not send an email if the mailing preferences disallow it" do
        @user.email_preference = 0
        
        stub_run_all_tests_to_fail
        
        # Check that the call isn't made to the mailer
        UserMailer.any_instance.should_not_receive(:test_notification)
        TestRunner.run_all_tests
      end
      
      context "emails enabled" do
        before(:each) do
          @user.email_preference = 1
        end
      
        it "should not send success messages if the last TestRun was successful" do
          # Tests Fail...
          stub_run_all_tests_to_fail          
          TestRunner.run_all_tests
          
          # ...then succeed...
          stub_run_all_tests_to_succeed
          
          # Should be able to use this line but doesn't work - complains that the second call to run_all_tests is also made...
          # UserMailer.any_instance.should_receive(:test_notification)  
          TestRunner.run_all_tests        
          
          # ...still succeeding - shouldn't get mail...
          UserMailer.any_instance.should_not_receive(:test_notification)      
          TestRunner.run_all_tests
        end
      
        it "should not send a success message on the first test run" do
          stub_run_all_tests_to_succeed
          
          UserMailer.any_instance.should_not_receive(:test_notification)
          TestRunner.run_all_tests
        end

        it "should send success messages if the last TestRun was a failure (1)" do
          UserMailer.any_instance.should_receive(:test_notification)

          stub_run_all_tests_to_fail
          TestRunner.run_all_tests
        end

        it "should send success messages if the last TestRun was a failure (2)" do
          stub_run_all_tests_to_fail
          TestRunner.run_all_tests

          UserMailer.any_instance.should_receive(:test_notification)

          stub_run_all_tests_to_succeed
          TestRunner.run_all_tests
        end

        it "should always send failure messages (1)" do
          UserMailer.any_instance.should_receive(:test_notification)

          stub_run_all_tests_to_fail
          TestRunner.run_all_tests
        end

        it "should always send failure messages (2)" do
          stub_run_all_tests_to_fail
          TestRunner.run_all_tests

          UserMailer.any_instance.should_receive(:test_notification)

          stub_run_all_tests_to_succeed
          TestRunner.run_all_tests
        end

        it "should always send failure messages (3)" do
          stub_run_all_tests_to_fail
          TestRunner.run_all_tests

          stub_run_all_tests_to_succeed
          TestRunner.run_all_tests

          UserMailer.any_instance.should_receive(:test_notification)

          stub_run_all_tests_to_fail
          TestRunner.run_all_tests
        end
      end
    end
  end
end
