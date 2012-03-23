require 'spec_helper'

describe Plan do
  before(:each) do
    plan = FactoryGirl.create(:plan, url_count: 2)
    @user1 = FactoryGirl.create(:user, plan: plan)
    @user1.test_files = [
      FactoryGirl.create(:test_file, user: @user1, compiled_test_file_text: "On http://dxw.com\n  I should see x\nOn http://dxw.com/1\n  I should see y")
    ]

    @user2 = FactoryGirl.create(:user, plan: plan)
    @user2.test_files = [
      FactoryGirl.create(:test_file, user: @user2, compiled_test_file_text: "On http://dxw.com\n  I should see x\nOn http://dxw.com/1\n  I should see y"),
      FactoryGirl.create(:test_file, user: @user2, compiled_test_file_text: "On http://dxw.com/3\n  I should see x")
    ]
  end

  it "should limit URLs in test files" do
    @user1.quota.should == {url_count: [2, 2]}
    @user1.over_quota?.should == false
    @user2.quota.should == {url_count: [3, 2]}
    @user2.over_quota?.should == true
  end
end
