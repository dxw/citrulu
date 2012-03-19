require 'spec_helper'
require 'testrunner'

describe TestRunner do
  describe "run_all_tests" do

    it "should not try and run tests where the compiled test file text is nil" do
      FactoryGirl.create(:test_file, :compiled_test_file_text => nil)
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end

    it "should not try and run tests where the compiled test file text is empty" do
      FactoryGirl.create(:test_file, :compiled_test_file_text => "")
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end

    describe "execute_test_groups" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @test_file = FactoryGirl.create(:test_file, :user => @user)
        @test_run = FactoryGirl.create(:test_run, :test_file => @test_file)

        # Don't actually send any email
        Mail::Message.any_instance.stub(:deliver)

        TestRunner.should_receive(:execute_tests).and_return([{
          :test_date => Time.now, :response_time => 200, :message => '', :test_url => 'http://example.com',
          :tests => [
            {:assertion => :i_see, :value => 'foo', :name => nil, :passed => true}
          ]
        }])
      end

      it "should create and save a new test group" do
        a_test_group = TestGroup.new
        a_test_group.should_receive('save!')
        TestGroup.should_receive(:new).and_return(a_test_group)

        TestRunner.execute_test_groups(@test_file, @test_run.id)
      end

      it "should create and save a new test result" do
        a_test_result = TestResult.new
        a_test_result.should_receive('save!')
        TestResult.should_receive(:new).and_return(a_test_result)

        TestRunner.execute_test_groups(@test_file, @test_run.id)
      end
    end

    describe "do_test" do
      it "should execute the block" do
        pending "I don't know how to test for this"
      end

      it "should return the value returned by the block" do
        TestRunner.do_test([:foo]) { true}.should be_true
      end
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
        pending
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
        pending
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

      it "should send success messages if the last TestRun was a failure (1)" do
        @user.email_preference = 1
        UserMailer.any_instance.should_receive(:test_notification)

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests
      end

      it "should send success messages if the last TestRun was a failure (2)" do
        @user.email_preference = 1

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests

        UserMailer.any_instance.should_receive(:test_notification)

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests
      end

      it "should always send failure messages (1)" do
        @user.email_preference = 1

        UserMailer.any_instance.should_receive(:test_notification)

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests
      end

      it "should always send failure messages (2)" do
        @user.email_preference = 1

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests

        UserMailer.any_instance.should_receive(:test_notification)

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests
      end

      it "should always send failure messages (3)" do
        @user.email_preference = 1

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group_no_failures)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests

        UserMailer.any_instance.should_receive(:test_notification)

        TestRunner.stub(:execute_test_groups) do |file,test_run_id|
          group = FactoryGirl.create(:test_group)
          group.test_run_id = test_run_id
          group.save!
        end
        TestRunner.run_all_tests
      end
    end
  end
end
