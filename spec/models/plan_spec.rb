# encoding: utf-8
require 'spec_helper'

describe Plan do
  before(:each) do
    plan = FactoryGirl.create(:plan, url_count: 2, test_file_count: 2)
    @user1 = FactoryGirl.create(:user, plan: plan)
    @user1.test_files = [
      FactoryGirl.create(:test_file, user: @user1, compiled_test_file_text: "On http://dxw.com\n  I should see x\nOn http://dxw.com/1\n  I should see y")
    ]

    @user2 = FactoryGirl.create(:user, plan: plan)
    @user2.test_files = [
      FactoryGirl.create(:test_file, user: @user2, compiled_test_file_text: "On http://dxw.com\n  I should see x\nOn http://dxw.com/1\n  I should see y"),
      FactoryGirl.create(:test_file, user: @user2, compiled_test_file_text: "On http://dxw.com/3\n  I should see x")
    ]

    plan = FactoryGirl.create(:plan, url_count: 6, test_file_count: 1)
    @user3 = FactoryGirl.create(:user, plan: plan)
    @user3.test_files = [
      FactoryGirl.create(:test_file, user: @user3, compiled_test_file_text: "On http://dxw.com\n  I should see x\nOn http://dxw.com/1\n  I should see y"),
      FactoryGirl.create(:test_file, user: @user3, compiled_test_file_text: "On http://dxw.com/3\n  I should see x")
    ]
  end

  it "should limit URLs in test files" do
    @user1.quota[:url_count].should == [2, 2]
    @user1.over_quota?.should == false
    @user2.quota[:url_count].should == [3, 2]
    @user2.over_quota?.should == true
  end

  it "should limit number of test files" do
    @user1.quota[:test_file_count].should == [1, 2]
    @user1.over_quota?.should == false
    @user3.quota[:test_file_count].should == [2, 1]
    @user3.over_quota?.should == true
  end

  it "should allow unlimited plans" do
    @user2.plan.url_count = -1
    @user2.plan.save!
    @user3.plan.test_file_count = -1
    @user3.plan.save!

    @user2.quota[:url_count].should == [3, '∞']
    @user2.over_quota?.should == false

    @user3.quota[:test_file_count].should == [2, '∞']
    @user3.over_quota?.should == false
  end
end
