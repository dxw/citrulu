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
  before(:each) do
    @console_hash = {:text0 => 'foobar', :blargh => 'barfoo'}
  end

  describe "console line" do
    it "should emit the text of the error" do
      helper.console_line(@console_hash).should include('foobar')
      helper.console_line(@console_hash).should include('barfoo')
    end

    it "should emit spans with the correct classes" do
      helper.console_line(@console_hash).should include('class="blargh"')
      helper.console_line(@console_hash).should include('<span')
    end
  end
end
