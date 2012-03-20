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
      FactoryGirl.create(:test_file, :compiled_test_file_text => nil)
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end

    it "should not try and run tests where the compiled test file text is empty" do
      FactoryGirl.create(:test_file, :compiled_test_file_text => "")
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end


#    describe "execute_tests" do
#      before(:each) do
#        Mechanize::HTTP::Agent.any_instance.stub(:fetch).and_return(Mechanize::Page.new)
#      end
#
#      def gimme_tests(code)
#        begin
#          CitruluParser.new.compile_tests(code)
#        rescue Exception => e
#          puts "Couldn't compile your test code"
#        end
#      end
#
#      it "should create a new mechanize agent for each group" do
#        Mechanize.should_receive(:new).twice
#        TestRunner.execute_tests(gimme_tests("On http://example.com\n  I should see foobar\n\nOn http://example.com\n  I should see foobar\n"))
#      end
#
#      it "should fetch the 'first' URL" do
#        Mechanize.any_instance.should_receive(:get).with('http://example.com/first')
#        TestRunner.execute_tests(gimme_tests("On http://example.com\n  First, fetch http://example.com/first\n  I should see foobar\n"))
#      end
#    end


    describe "execute_test_groups" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @test_file = FactoryGirl.create(:test_file, :user => @user)
        @test_run = FactoryGirl.create(:test_run, :test_file => @test_file)

        # Don't actually send any email
        Mail::Message.any_instance.stub(:deliver)
      end

      it "should throw TestRunner::TestCompileError if it receives CitruluParser::TestCompileError" do
        CitruluParser.any_instance.should_receive(:compile_tests).and_raise(CitruluParser::TestCompileError)
        expect {TestRunner.execute_test_groups(FactoryGirl.create(:test_file, :compiled_test_file_text => 'fladgebagger'), @test_run.id)}.to raise_error(TestRunner::TestCompileError)
      end

      describe "create and save results" do
        before(:each) do
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
        # Don't actually send any email!
        Mail::Message.any_instance.stub(:deliver)
      end

      it "should send an email if the mailing preferences allow it" do
        pending
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
