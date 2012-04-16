require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
    
    @subscriber = double(RSpreedly::Subscriber)
    RSpreedly::Subscriber.stub(:new).and_return(@subscriber)
    RSpreedly::Subscriber.stub(:find) # By default, return nil (not found)
    RSpreedly::Subscriber.any_instance.stub(:update)
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
    
    RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
    @subscriber.stub(:destroy)
    
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
  
  context "when dealing with Spreedly" do
    before(:each) do
      @plan = FactoryGirl.create(:plan)
      @user.plan = @plan
    end
    
    describe "create_subscriber" do
      it "should create a subscriber record on spreedly" do
        RSpreedly::Subscriber.should_receive(:new)
        @subscriber.should_receive(:save!)
        @user.create_subscriber
      end
    end
  
    describe "update_subscription_details" do
      it "should raise an error if the hash included :update_subscription_plan" do
        @plan2 = FactoryGirl.create(:plan, name_en: 'Another Plan')
        expect{ @user.update_subscription_details(:update_subscription_plan => @plan) }.to raise_error(ArgumentError)
      end
    end
  
    describe "callbacks" do
      it "should destroy the subscription when the model is destroyed" do
        RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
        @subscriber.should_receive(:destroy)
        @user.destroy
      end
    end
  end
  
end
