require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  
  it "should add the default test file when it's created" do
    @user.test_files.first.test_file_text.should == DEFAULT_TEST_FILE
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
end
