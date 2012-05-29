require 'spec_helper'

describe Response do
  before(:each) do
    @user = FactoryGirl.create(:user)
    test_file = FactoryGirl.create(:test_file, user: @user)
    test_run = FactoryGirl.create(:test_run, test_file: test_file, time_run: "2012-01-01 00:01:20 UTC" )
    @myresponse = FactoryGirl.create(:response, code: "404" )
    FactoryGirl.create(:test_group, response: @myresponse, test_run: test_run, test_url: "http://www.foo.com" )
  end
  
  describe "name" do   
    it "should return a string using elements of the response, group and run" do
      @myresponse.name.should == "404::http://www.foo.com::2012-01-01 00:01:20 UTC"
    end
  end
  
  describe "owner" do   
    it "should return the user who owns the corresponding text file" do
      @myresponse.owner.should == @user
    end
  end
end


