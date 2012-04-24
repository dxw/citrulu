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
      @user.confirm!
      @user.plan = @plan  
      @user.save!
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
    
    describe "update_subscriber" do
      before(:each) do
        RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
        
      end
      
      context "when there have been changes to the user" do
        it "should update the Spreedly subscriber" do
          @subscriber.should_receive(:update!)
          
          @subscriber.stub(:respond_to?).and_return(true)
          @subscriber.stub(:send)
          
          @user.email = "faz@baz.com"
          @user.send(:update_subscriber)
        end
      end
      context "when there have NOT been changes to the user" do
        it "should not update the Spreedly subscriber" do
          @subscriber.should_not_receive(:update!)
          @user.send(:update_subscriber)
        end
      end
    end
  
    describe "callbacks" do
      it "should destroy the subscription when the model is destroyed" do
        RSpreedly::Subscriber.stub(:find).and_return(@subscriber)
        @subscriber.should_receive(:destroy)
        @user.destroy
      end
      
      it "should do nothing if the model was destroyed but there is no subscriber" do
        RSpreedly::Subscriber.stub(:find).and_return(nil)
        RSpreedly::Subscriber.any_instance.should_not_receive(:destroy)
        @user.destroy
      end
    end
  end
  
  
  context "when calculating free trial periods" do
    describe ".is_within_free_trial" do
      before(:all) do
        @free_trial_days = 30 #doesn't seem to get pulled from config...
      end
      before(:each) do
        @user.confirm!
      end
      it "should return true if the user is active and was created less than x days ago" do
        Timecop.travel(Time.now + (@free_trial_days -1).days)
        @user.active = true
        @user.is_within_free_trial?.should be_true
      end
    
      it "should return false if the user is active and was created MORE than x days ago" do
        Timecop.travel(Time.now + (@free_trial_days +1).days)
        @user.active = true
        @user.is_within_free_trial?.should be_false
      end
    
      it "should return false if the user was created less than x days ago but is inactive" do
        @user.active = false
        @user.is_within_free_trial?.should be_false
      end
    end
  end
end