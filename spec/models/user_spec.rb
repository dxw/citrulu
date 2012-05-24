require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  
  it "should add the tutorial test files when it's created" do
    @user.test_files.last.test_file_text.should == TUTORIAL_TEST_FILES.first[:text]
  end
  
  it "should set the email preference to recieve test run emails when it's created" do
    @user.email_preference.should == 1
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
    @user.destroy
    expect{ TestFile.find(test_file_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
  
  
  describe ".save" do
    before(:each) do 
      @code = "foo"
      @invitation = FactoryGirl.create(:invitation, :code => @code)
      @user1= FactoryGirl.build(:user)
    end
    
    it "should set an invitation id when the user is saved for the first time" do
      @user1.invitation_code = @code
      @user1.save
      @user1.invitation_id.should == @invitation.id
    end
    
    it "should retain the invitation id when the user is saved for the second time" do
      @user1.invitation_code = @code
      @user1.save
      
      @user1.invitation_code = nil
      #Change something:
      @user1.password = "somethingdifferent"
      @user1.save
      
      @user1.invitation_id.should == @invitation.id
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
    
      it "should return 'New test file1'" do
        @user.new_test_file_name.should == 'New test file1'
      end
      
      context "and if a test file exists with a different name" do
        before(:each) do
          FactoryGirl.create(:test_file, user: @user, name: 'Foo')
        end
      
        it "should return 'New test file1'" do
          @user.new_test_file_name.should == 'New test file1'
        end
      end
      
      context "and if 'New test file1' exists" do
        before(:each) do
          FactoryGirl.create(:test_file, user: @user, name: 'New test file1')
        end
      
        it "should return 'New test file2'" do
          @user.new_test_file_name.should == 'New test file2'
        end
      end
    end
  end
  
  describe "create_tutorial_test_files" do
    it "should execute without errors" do
      @user.create_tutorial_test_files.should_not raise_error
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
  end
end
