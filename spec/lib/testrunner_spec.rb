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
  
  describe "execute_tests" do
    
    
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
              { :assertion => :i_see, :value => 'foo', :name => nil, :result => true }
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
        @test_run.test_groups[0].test_results[0].assertion.should == 'I should see'
        @test_run.test_groups[0].test_results[0].value.should == 'foo'
        @test_run.test_groups[0].test_results[0].name.should == nil
        @test_run.test_groups[0].test_results[0].result.should == true
      end
    end
  end
  
  describe "get_test_results" do
    before(:each) do
      TestRunner.stub(:get_test_values).and_return(["foo"])
    end
    
    context "(text in page:)" do
      def mock_match_text_in_page(truth)
        TestRunner.should_receive(:text_is_in_page?).twice.and_return(truth)
      end
    
      it "should handle i_see correctly when there is a match" do
        mock_match_text_in_page(true)
      
        tests = [{:assertion => :i_see}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result].should == true
      end
    
      it "should handle i_see correctly when there is no match" do
        mock_match_text_in_page(false)
      
        tests = [{:assertion => :i_see}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result].should == false
      end
    
      it "should handle i_not_see correctly when there is a match" do
        mock_match_text_in_page(true)
      
        tests = [{:assertion => :i_not_see}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result].should == false
      end
    
      it "should handle i_not_see correctly when there is no match" do
        mock_match_text_in_page(false)
      
        tests = [{:assertion => :i_not_see}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result].should == true
      end
    end
    
    context "(source in page:)" do
      def mock_match_source_in_page(truth)
        TestRunner.should_receive(:source_is_in_page?).twice.and_return(truth)
      end
    
      it "should handle source_contain correctly when there is a match" do
        mock_match_source_in_page(true)
      
        tests = [{:assertion => :source_contain}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == true
      end
    
      it "should handle source_contain correctly when there is no match" do
        mock_match_source_in_page(false)
      
        tests = [{:assertion => :source_contain}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == false
      end
      
      it "should handle source_not_contain correctly when there is a match" do
        mock_match_source_in_page(true)
      
        tests = [{:assertion => :source_not_contain}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == false
      end
    
      it "should handle source_not_contain correctly when there is no match" do
        mock_match_source_in_page(false)
      
        tests = [{:assertion => :source_not_contain}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == true
      end
    end
    
    context "(headers in page:)" do
      def mock_match_headers_in_page(truth)
        TestRunner.should_receive(:header_is_in_page?).twice.and_return(truth)
      end
    
      it "should handle headers_include correctly when there is a match" do
        mock_match_headers_in_page(true)
      
        tests = [{:assertion => :headers_include}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == true
      end
    
      it "should handle headers_include correctly when there is no match" do
        mock_match_headers_in_page(false)
      
        tests = [{:assertion => :headers_include}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == false
      end
      
      it "should handle headers_include correctly when there is a match" do
        mock_match_headers_in_page(true)
      
        tests = [{:assertion => :headers_not_include}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == false
      end
    
      it "should handle headers_include correctly when there is no match" do
        mock_match_headers_in_page(false)
      
        tests = [{:assertion => :headers_not_include}]
        TestRunner.get_test_results(nil, tests).length.should == 1
        TestRunner.get_test_results(nil, tests)[0][:result]. should == true
      end
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
  
  describe "header_is_in_page?" do
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
      TestRunner.do_test([:foo]) { true }.should be_true
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
