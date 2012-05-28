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
   
    test_file.destroy
    
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
  
  describe "self.compiled_files" do
    it "should only return successfully compiled files" do
      TestFile.compiled_files.should==[@test_file_compiled_text]
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
end
