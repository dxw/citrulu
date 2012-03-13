require 'spec_helper'
require 'testrunner'

describe TestRunner do
  describe "run_all_tests" do

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
        # Don't actually run any tests:
        TestRunner.stub(:execute_test_groups)
        # Don't actually send any email!
        Mail::Message.any_instance.stub(:deliver)
      end

      it "should send an email if the mailing preferences allow it" do
        @user.email_preference = 1
        # Check that the call is made to the mailer
        UserMailer.any_instance.should_receive(:test_notification)
        TestRunner.run_all_tests
      end

      it "should not send an email if the mailing preferences disallow it" do
        @user.email_preference = 0
        # Check that the call isn't made to the mailer
        UserMailer.any_instance.should_not_receive(:test_notification)
        TestRunner.run_all_tests
      end

      it "should not send success messages if the last TestRun was successful" do
        @user.email_preference = 1

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
        end
        UserMailer.any_instance.should_receive(:test_notification)
        TestRunner.run_all_tests

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
        end
        UserMailer.any_instance.should_not_receive(:test_notification)
        TestRunner.run_all_tests
      end

      it "should send success messages if the last TestRun was a failure" do
        pending "test doesn't work"
        @user.email_preference = 1

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        UserMailer.any_instance.should_receive(:test_notification).once
        TestRunner.run_all_tests

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
          group.test_run_id = test_run_id
          group.save!
        end
        UserMailer.any_instance.should_receive(:test_notification).once
        p 'waiting for test_not'
        TestRunner.run_all_tests
        p 'end test'
      end

      it "should always send failure messages" do
        pending "test doesn't work"
        @user.email_preference = 1

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        UserMailer.any_instance.should_receive(:test_notification)
        TestRunner.run_all_tests

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
          group.test_run_id = test_run_id
          group.save!
        end
        UserMailer.any_instance.should_receive(:test_notification)
        TestRunner.run_all_tests

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        UserMailer.any_instance.should_receive(:test_notification)
        TestRunner.run_all_tests
      end
    end
  end
end
