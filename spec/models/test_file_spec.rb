require 'spec_helper'

describe TestFile do
  before(:each) do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    
    # Test Files:
    @test_file_compiled_text = FactoryGirl.create(:test_file, :compiled_test_file_text => "foobar", user: user1) 
    @test_file_compiled_nil = FactoryGirl.create(:test_file, :compiled_test_file_text => nil, user: user1)
    @test_file_compiled_empty = FactoryGirl.create(:test_file, :compiled_test_file_text => "", user: user2)
    
    # Test Runs:
    FactoryGirl.create(:test_run, :test_file => @test_file_compiled_text, :time_run => Time.now-1)
    @test_run2 = FactoryGirl.create(:test_run, :test_file => @test_file_compiled_text, :time_run => Time.now) 
    
    @test_run3 = FactoryGirl.create(:test_run, :test_file => @test_file_compiled_nil, :time_run => Time.now)
    FactoryGirl.create(:test_run, :test_file => @test_file_compiled_nil, :time_run => Time.now-1)
  end
  
  it "should delete dependent test runs when it is deleted" do
    test_file = FactoryGirl.create(:test_file)
    test_run = FactoryGirl.create(:test_run, :test_file => test_file)
    test_run_id = test_run.id
    
    test_run_id = @test_run2.id
    @test_file_compiled_text.destroy
    
    expect{ TestRun.find(test_run_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
  
  describe "owner" do
    it "should return the user that owns the file" do
      user = FactoryGirl.create(:user)
      test_file = FactoryGirl.create(:test_file, :user => user)

      test_file.owner.should == user
    end
  end

  describe "last_run" do
    it "should return the most recent test run for the file" do
      @test_file_compiled_text.last_run.should== @test_run2
    end
  
    it "should return the most recent test run for the if IDs are out of order" do
      @test_file_compiled_nil.last_run.should== @test_run3
    end
  end
  
  describe "due" do
    context "when the user is on a plan which runs tests hourly" do
      before(:each) do
        Timecop.freeze
        @test_file = FactoryGirl.create(:test_file, frequency: 1.hour)
      end
      
      context "when the test_file is set to not run" do
        before(:each) do
          @test_file.run_tests = false
        end
        it "should return false" do
          @test_file.due.should be_false
        end
      end
      
      context "when the test_file has never been run" do
        it "should return true" do
          @test_file.due.should be_true
        end
      end
      
      context "when the test_file was last run under one hour ago" do
        before(:each) do
          @test_run = FactoryGirl.create(:test_run, test_file: @test_file, time_run: (Time.now - 1.hour) + 1)
          TestFile.any_instance.stub(:last_run).and_return(@test_run)
        end
        it "should return false" do
          @test_file.due.should be_false
        end
      end
      
      context "when the test_file was last run over one hour ago" do
        before(:each) do
          @test_run = FactoryGirl.create(:test_run, test_file: @test_file, time_run: (Time.now - 1.hour) - 1)
          TestFile.any_instance.stub(:last_run).and_return(@test_run)
        end
        it "should return true if the file is active" do
          @test_file.due.should be_true
        end

        it "should raise an error if the file is deleted" do
          @test_file.deleted = true
          expect { @test_file.due }.to raise_error
        end
        it "should return false if the file is not set to run" do
          @test_file.run_tests = false
          @test_file.due.should be_false
        end
      end
    end
  end
  
  describe "compiled?" do
    it "should return true if compiled_test_file_text contains text" do
      @test_file_compiled_text.compiled?.should be_true
    end
    
    it "should return false if compiled_test_file_text is nil" do
      @test_file_compiled_nil.compiled?.should be_false
    end
    
    it "should return false if compiled_test_file_text is empty" do
      @test_file_compiled_empty.compiled?.should be_false
    end
  end
  
  context "(functions for getting stats)" do
    before(:each) do
      compiled_test_file_text = 
        "On http://foo.com\n  I should see foo\n\n" +
        "On http://bar.com\n  I should see bar\n\n" +
        "On http://faz.com\n  I should see faz\n"
      @test_file = FactoryGirl.create(:test_file, :compiled_test_file_text => compiled_test_file_text)
    end    
    
    describe "number_of_pages" do
      it "should return 3 if there are 3 pages" do
        @test_file.number_of_pages.should == 3
      end
    
      it "should raise an error if the file has never compiled" do
        expect { @test_file_compiled_nil.number_of_pages }.to raise_error(ArgumentError)
      end
    end
  
    describe "number_of_tests" do
      it "should return 6 if there are 3 checks in 3 pages" do
        # 3 natural checks, 3 injected checks for response code == 200
        @test_file.number_of_tests.should == 6
      end
      
      it "should return 7 if there are 2 checks on 1 page and 3 on another" do
        # 5 natural checks, 2 injected checks for response code == 200
        compiled_test_file_text = 
          "On http://foo.com\n  I should see foo\n  I should not see faz\n" +
          "On http://bar.com\n  Source should contain bar\n  Source should not contain baz\n  Headers should not include tizzwoz"
        test_file = FactoryGirl.create(:test_file, :compiled_test_file_text => compiled_test_file_text)
        
        test_file.number_of_tests.should == 7
      end
    
      it "should raise an error if the file has never compiled" do
        expect { @test_file_compiled_nil.number_of_tests }.to raise_error(ArgumentError)
      end
    end
    
    describe "delete!" do
      it "should set 'deleted' to true (and save)" do
        @test_file.delete!
        
        #Check that the object has been saved
        @test_file.changed?.should be_false
        @test_file.deleted.should be_true
      end
    end
    
    describe "not_deleted" do 
      it "should not return deleted test files" do
        deleted_test_file = FactoryGirl.create(:test_file, deleted: true)
        TestFile.not_deleted.should_not include(deleted_test_file)
      end
    end
  end
  
  describe "next_tutorial" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.test_files.destroy_all
      @test_file = FactoryGirl.create(:test_file, user: @user, tutorial_id:0)
    end
    
    context "when a next file exists" do
      it "should return the next tutorial file" do
        next_test_file = FactoryGirl.create(:test_file, user: @user, tutorial_id:2)
        FactoryGirl.create(:test_file, user: @user, tutorial_id:5)
        
        @test_file.next_tutorial.should == next_test_file
      end
    end
    context "when a next file does not exist" do
      it "should return nil" do
        @test_file.next_tutorial.should == nil
      end
    end
  end 
  
  describe "is_a_tutorial" do
    it "should return true if tutorial_id is not nil" do
      FactoryGirl.create(:test_file, tutorial_id: 1).is_a_tutorial.should be_true
    end
    it "should return false if tutorial_id is nil" do
      FactoryGirl.create(:test_file, tutorial_id: nil).is_a_tutorial.should be_false
    end
  end
  
  describe "(resque methods)" do
    before(:each) do
      Resque.stub(:enqueue)
      Resque.stub(:dequeue)
      
      @test_file = FactoryGirl.create(:test_file)
    end
    describe "enqueue" do
      it "should call Resque and enqueue with TestFileJob" do
        Resque.should_receive(:enqueue).with(TestFileJob, anything())
        @test_file.enqueue
      end
    end
    describe "priority_enqueue" do
      it "should call Resque and enqueue with PriorityTestFileJob" do
        Resque.should_receive(:enqueue).with(PriorityTestFileJob, anything())
        @test_file.priority_enqueue
      end
    end
    describe "prioritise" do
      it "should call Resque and dequeue with TestFileJob" do
        Resque.should_receive(:dequeue).with(TestFileJob, anything())
        @test_file.prioritise
      end
      it "should call Resque and enqueue with PriorityTestFileJob" do
        Resque.should_receive(:enqueue).with(PriorityTestFileJob, anything())
        @test_file.prioritise
      end
    end
  end
 
end
