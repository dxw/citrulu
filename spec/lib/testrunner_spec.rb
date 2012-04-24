require 'spec_helper'
require 'testrunner'

describe TestRunner do
  describe "run_all_tests" do
    
    def stub_execute_test_groups_to_succeed
      TestRunner.stub(:execute_test_groups) do |file,test_run|
        FactoryGirl.create(:test_group_no_failures, :test_run => test_run)
      end
    end
    
    def stub_execute_test_groups_to_fail
      TestRunner.stub(:execute_test_groups) do |file,test_run|
        FactoryGirl.create(:test_group_with_failures, :test_run => test_run)
      end
    end
    
    it "should raise an exception if a test file is orphaned" do
      FactoryGirl.create(:compiled_test_file)
      FactoryGirl.create(:compiled_test_file, :user => nil)
      FactoryGirl.create(:compiled_test_file)
      expect { TestRunner.run_all_tests }.to raise_error(RuntimeError)
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
    
    it "should not try and run tests where the user is inactive" do
      user = FactoryGirl.create(:user, active: false)
      FactoryGirl.create(:test_file, user: user)
      
      TestRunner.should_not_receive(:execute_test_groups)
      TestRunner.run_all_tests
    end

    describe "(sending email)" do
      before(:each) do
        # Don't actually send any email!
        Mail::Message.any_instance.stub(:deliver)
      end
      
      context "when emails are disabled" do
        before(:each) do
          @user = FactoryGirl.create(:user, :email_preference => 0)
          @test_file = FactoryGirl.create(:test_file, :user => @user)
          # Make sure there's something to run tests on:
          # TestFile.stub(:compiled_files).and_return([@test_file])
        end
        
        it "should not send an email" do  
          stub_execute_test_groups_to_fail

          # Check that the call isn't made to the mailer
          UserMailer.should_not_receive(:test_notification)
          TestRunner.run_all_tests
        end
      end
      
      
      context "when emails are enabled" do
        before(:each) do
          @user = FactoryGirl.create(:user, :email_preference => 1)
          @test_file = FactoryGirl.create(:test_file, :user => @user)
        end
        
        it "should not send success messages if the last TestRun was successful" do
          # Tests Fail...
          stub_execute_test_groups_to_fail          
          TestRunner.run_all_tests
          
          # ...then succeed...
          stub_execute_test_groups_to_succeed
          
          # Should be able to use this line but doesn't work - complains that the second call to run_all_tests is also made...
          # UserMailer.should_receive(:test_notification)  
          TestRunner.run_all_tests        
          
          stub_execute_test_groups_to_succeed
          
          # ...still succeeding - shouldn't get mail...
          UserMailer.should_not_receive(:test_notification_success)      
          TestRunner.run_all_tests
        end
      
        it "should not send a success message on the first test run" do
          stub_execute_test_groups_to_succeed
          
          UserMailer.should_not_receive(:test_notification_success)
          TestRunner.run_all_tests
        end

        it "should send success messages if the last TestRun was a failure" do
          stub_execute_test_groups_to_fail
          TestRunner.run_all_tests

          UserMailer.should_receive(:test_notification_success).and_return(Mail::Message.new)

          stub_execute_test_groups_to_succeed
          TestRunner.run_all_tests
        end

        it "should always send failure messages (1)" do
          UserMailer.should_receive(:test_notification_failure).and_return(Mail::Message.new)

          stub_execute_test_groups_to_fail
          TestRunner.run_all_tests
        end
        
        it "should always send failure messages (2)" do
          stub_execute_test_groups_to_fail
          TestRunner.run_all_tests
          
          UserMailer.should_receive(:test_notification_failure).and_return(Mail::Message.new)

          TestRunner.run_all_tests
        end

        it "should send a failure message if the tests were succeeding but are now failing (1)" do
          stub_execute_test_groups_to_succeed
          TestRunner.run_all_tests
          
          UserMailer.should_receive(:test_notification_failure).and_return(Mail::Message.new)

          stub_execute_test_groups_to_fail
          TestRunner.run_all_tests
        end

        it "should send a failure message if the tests were succeeding but are now failing (2)" do
          stub_execute_test_groups_to_fail
          TestRunner.run_all_tests

          stub_execute_test_groups_to_succeed
          TestRunner.run_all_tests

          UserMailer.should_receive(:test_notification_failure).and_return(Mail::Message.new)

          stub_execute_test_groups_to_fail
          TestRunner.run_all_tests
        end
        
        
        it "should send a failure message when groups have failed but no tests have failed" do
          # "group has failed" == "page could not be retrieved" == "message is not nil"          
          TestFile.stub(:execute_test_groups) do |file,test_run|
            FactoryGirl.create(:test_group_no_failures, :message => "I have failed", :test_run => test_run)
          end
          
          UserMailer.should_receive(:test_notification_failure).and_return(Mail::Message.new)
          
          TestRunner.run_all_tests
        end
      end
    end
  end
  
  describe ".execute_tests" do
    before(:each) do  
      @dummy_page = FactoryGirl.build(:mechanize_page)
    end
    
    def stub_mechanize(dummy_page=nil)
      dummy_page ||= @dummy_page
      Mechanize.any_instance.stub(:get).and_return(dummy_page)
    end
    
    it "should inherit values from the compiled object" do  
      url = "http://foo.com"

      test_groups = [
        {:page => {:url => url, :method => "get"}}
      ]
      
      test_group_params = TestRunner.execute_tests(test_groups)
      test_group_params[0][:test_url].should == url
    end
    
    it "should fetch the 'first' URL" do
      test_groups = [
        {:page => {:url => "http://example.com/", :method => "get"}, :first => "http://example.com/first"}
      ]
      # Get first:
      Mechanize.any_instance.should_receive(:get).with("http://example.com/first")
      # Get the page:
      Mechanize.any_instance.should_receive(:get).with("http://example.com/",nil).and_return(@dummy_page) 
      
      TestRunner.execute_tests(test_groups)
    end
    
    it "should set time_run to the current time" do
      pending("There's a railscast on how to freeze time...")
    end
    
    
    context "when the 'page' object could not be retrived" do
      before(:each) do
        @test_groups = [
          {:page => {:url => "foo", :method => "get"}} # get will always fail, since this is not a valid URL
        ]
      end
    
      it "should set a message on the group when the Mechanize object page could not be retrived" do
        TestRunner.execute_tests(@test_groups)[0][:message].should_not be_blank
      end
      
      it "should not fetch the 'finally' URL" do
        @test_groups = [
          {:page => {:url => "foo", :method => "get"}, :finally => "http://example.com/finally"}
        ]
        Mechanize.any_instance.should_not_receive(:get).with('http://example.com/finally')
      end
      
      it "should not set the response time" do
        TestRunner.execute_tests(@test_groups)[0][:response_time].should be_blank
      end
      
      it "should not set a response code" do
        TestRunner.execute_tests(@test_groups)[0][:response_code].should be_blank
      end
      
      it "should not set test results" do
        TestRunner.execute_tests(@test_groups)[0][:test_results_attributes].should be_blank
      end
    end
    
    context "when the 'page' object is successfully retrived" do
      before(:each) do
        @test_groups = [
          {:page => {:url => "http://example.com/", :method => "get"}}
        ]
      end
      
      it "should fetch the 'finally' URL" do
        test_groups = [
          {:page => {:url => "http://example.com/", :method => "get"}, :finally => "http://example.com/finally"}
        ]
        # Get the page:
        Mechanize.any_instance.should_receive(:get).with("http://example.com/",nil).and_return(@dummy_page) 
        # Get finally:
        Mechanize.any_instance.should_receive(:get).with("http://example.com/finally")
        
        TestRunner.execute_tests(test_groups)
      end  
        
        
      it "should set the response time" do
        pending("There's a railscast on how to freeze time...")
        stub_mechanize
        TestRunner.execute_tests(test_groups)[0][:response_code].should == "X"
      end
      
      it "should set the response code" do
        dummy_page = FactoryGirl.build(:mechanize_page, :code => 404)
        stub_mechanize(dummy_page)
        
        TestRunner.execute_tests(@test_groups)[0][:response_code].should == 404
      end
      
      it "should generate the test results" do
        stub_mechanize(@dummy_page)
        test_groups = [
          {:page => {:url => "http://example.com/", :method => "get"}, :tests => "bar"}
        ]
      
        TestRunner.should_receive(:get_test_results).with(@dummy_page,"bar")
        
        TestRunner.execute_tests(test_groups)
      end
        
      it "should set a message on the group when it can't retrieve one of the test_results" do
        stub_mechanize
        TestRunner.stub(:get_test_results).and_raise(RuntimeError.new("faz"))
        
        TestRunner.execute_tests(@test_groups)[0][:message].should == "faz"
      end
    end  
  end


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

    describe "(create and save results)" do
      before(:each) do
        TestRunner.should_receive(:execute_tests).and_return(
          [
            :time_run => Time.now, :response_time => 200, :message => '', :test_url => 'http://example.com',
            :test_results_attributes => [
              { :result => true, :original_line => "I should see foo" }
            ]
          ]
        )
      end

      it "should create and save a new test group" do
        TestRunner.execute_test_groups(@test_file, @test_run)

        @test_run.test_groups.length.should == 1
        @test_run.test_groups[0].response_time.should == 200
        @test_run.test_groups[0].message.should == ''
        @test_run.test_groups[0].test_url.should == 'http://example.com'
      end

      it "should create and save a new test result" do
        TestRunner.execute_test_groups(@test_file, @test_run)
        
        @test_run.test_groups[0].test_results.length.should  == 1
        @test_run.test_groups[0].test_results[0].result.should == true
        @test_run.test_groups[0].test_results[0].original_line.should == "I should see foo"
      end
    end
  end
  
  describe "get_test_results" do
    before(:each) do
      TestRunner.stub(:get_test_values).and_return(["foo"])
    end
    
    it "inherits values from the parser output" do
      TestRunner.stub( :text_is_in_page? )
      
      assertion = :i_see
      original_line = "I should see foo"
      value = "foo"
      name = ":a_name"
      
      test_results = [
        {
          :assertion => assertion,
          :original_line => original_line,
          :value => value,
          :name => name
        }
      ]
      
      test_result_params = TestRunner.get_test_results(nil,test_results)
      test_result_params[0][:original_line].should == original_line
    end
    
    
    
    shared_examples_for "an assertion" do
      # Approach: all the assertions follow the same pattern, so we define
      # a couple of steps to check that the truth of the assertion works correctly
      # i.e. if the check in the page is true then
      #    a "should" assertion should evaluate to true
      #    a "should not" assertion should evaluate to false
      # The actual checks themselves are tested seperately.

      it "returns the correct result" do
        TestRunner.should_receive(page_check).twice.and_return(matches)
      
        tests = [{:assertion => assertion}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result].should == expected_result
      end
    end
        
    context "when checking for text in the page" do 
      let(:page_check) { :text_is_in_page? }
      
      context "using i_see" do
        let(:assertion) { :i_see }
        
        it_behaves_like "an assertion" do
          let(:matches) { true }     
          let(:expected_result) { true }
        end
      
        it_behaves_like "an assertion" do
          let(:matches) { false }
          let(:expected_result) { false }
        end
      end
      
      context "using i_not_see" do
        let(:assertion) { :i_not_see }
        
        it_behaves_like "an assertion" do
          let(:matches) { true }
          let(:expected_result) { false }
        end
      
        it_behaves_like "an assertion" do
          let(:matches) { false }
          let(:expected_result) { true }
        end
      end
    end
    
    context "when checking for source in the page" do
      let(:page_check) { :source_is_in_page? }
      
      context "using source_contain" do
        let(:assertion) { :source_contain }
      
        it_behaves_like "an assertion" do
          let(:matches) { true }
          let(:expected_result) { true }
        end

        it_behaves_like "an assertion" do
          let(:matches) { false }
          let(:expected_result) { false }
        end
      end
      
      context "using source_not-contain" do
        let(:assertion) { :source_not_contain }
        
        it_behaves_like "an assertion" do
          let(:matches) { true }
          let(:expected_result) { false }
        end
        
        it_behaves_like "an assertion" do
          let(:matches) { false }
          let(:expected_result) { true }
        end
      end
    end
    
    context "when checking for headers in the page" do
      let(:page_check) { :header_exists? }
      
      context "using headers_include" do
        let(:assertion) { :headers_include }
        it_behaves_like "an assertion" do
          let(:matches) { true }

          let(:expected_result) { true }
        end

        it_behaves_like "an assertion" do
          let(:matches) { false }
          let(:assertion) { :headers_include }
          let(:expected_result) { false }
        end
      end
      
      context "using headers_not_include" do
        let(:assertion) { :headers_not_include }
        
        it_behaves_like "an assertion" do
          let(:matches) { true }
          let(:expected_result) { false }
        end

        it_behaves_like "an assertion" do
          let(:matches) { false }
          let(:expected_result) { true }
        end
      end
    end 
    
    it "should throw an error if an assertion is not recognised" do
      tests = [{:assertion => "foo"}]
      expect {TestRunner.get_test_results(nil, tests)}.to raise_error
    end 
  end
  
  
  describe "text_is_in_page?" do    
    it "should return true when the text is in the page" do
      pending("Testing this requires stubbing out Mechanize...")
    end
    it "should return false when the text is not in the page" do
      pending("Testing this requires stubbing out Mechanize...")
    end
  end
    
  describe "source_is_in_page?" do
    it "should return true when the source is in the page" do
      pending("Testing this requires stubbing out Mechanize...")
    end
    it "should return false when the source is not in the page" do
      pending("Testing this requires stubbing out Mechanize...")
    end
  end
  
  describe "header_exists?" do
    it "should return true when the header is in the page" do
      pending("Testing this requires stubbing out Mechanize...")
    end
    it "should return false when the header is not in the page" do
      pending("Testing this requires stubbing out Mechanize...")
    end
  end


  describe "do_test" do
    it "should return true if all values equate to true" do
      testvalues = ["true", "true", "true"]
      TestRunner.do_test(testvalues) {|str| eval(str)}.should be_true
    end
  
    it "should return false if one value equates to true" do
      testvalues = ["true", "false", "true"]
      TestRunner.do_test(testvalues) {|str| eval(str)}.should be_false
    end  

    it "should return the value returned by the block" do
      TestRunner.do_test(["foo"]) { true }.should be_true
    end
  end
  
  
  describe "get_test_values" do
    it "should return the value in an array if the value is not blank" do 
      test = {}
      test[:value] = "foo"
      TestRunner.get_test_values(test).should == ["foo"]
    end
    
    it "should return the list of predefs if the value is blank and there is a name which matches a predef" do
      @predef_list = ["a thing", "another thing"]
      Predefs.stub(:find).and_return(@predef_list)
      
      test = {}
      test[:name] = "foo"
      TestRunner.get_test_values(test).should == @predef_list
      TestRunner.get_test_values(test).class.should == Array
    end
    
    it "should throw an Exception if the value is blank and there is a name which doesn't match a predef" do      
      test = {}
      test[:name] = "foo"
      expect {TestRunner.get_test_values(test)}.to raise_error(Predefs::PredefNotFoundError)
    end
    
    it "should throw an Exception if both the value and name are blank" do      
      test = {}
      expect {TestRunner.get_test_values(test)}.to raise_error
    end
  end
end
