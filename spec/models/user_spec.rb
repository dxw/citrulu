require 'spec_helper'

describe User do
  it "should add the default test file when it's created" do
    user = FactoryGirl.create(:user)
    user.test_files.first.test_file_text.should == DEFAULT_TEST_FILE
  end 
end
