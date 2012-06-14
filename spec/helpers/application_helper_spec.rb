require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the TestFilesHelper. For example:
#
# describe TestFilesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe TestFilesHelper do
  describe "controller_name" do
    it "should return the name of a simple controller" do
      params[:controller] = 'baz'
      helper.controller_name.should == 'baz'
    end
    
    it "should return the name of a nested controller" do
      params[:controller] = 'foo/bar'
      helper.controller_name.should == 'foo bar'
    end
  end

  describe "nav_link" do
    it "should return an <a> element with no class if the href is not the current page" do
      @request.stub!(:fullpath).and_return('/foo')

      helper.nav_link('foo', '/bar').should_not include('class')
      helper.nav_link('foo', '/bar').should_not include('active')
    end

    it "should return an <a> element with the class 'active' if the href is the current page" do
      @request.stub!(:fullpath).and_return('/foo')

      helper.nav_link('foo', '/foo').should include('class')
      helper.nav_link('foo', '/foo').should include('active')
    end
  end

  describe "flash_message" do
    it "should contain the message" do
      helper.flash_message(:foo, 'bar').should include('bar')
    end

    it "should contain a class" do
      helper.flash_message(:alert, 'bar').should include('class=')
    end
  end
  
  describe "twitter_button" do
    it "should render a link" do
      helper.twitter_button.should include("<a href=")
    end
  end
  
  describe "unimplemented_popover" do
    it "should render a link" do
      helper.unimplemented_popover("foo").should include("<a href=")
    end
    it "should be disabled" do
      helper.unimplemented_popover("foo").should include("onclick=\"return false;\"")
    end
    it "should have a popover title and text" do
      helper.unimplemented_popover("foo").should include("data-original-title=")
      helper.unimplemented_popover("foo").should include("data-content=")
    end
  end

end
