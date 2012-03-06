require 'spec_helper'

describe CitruluParser do
  describe "compile_tests" do
    it "should raise an exception if the input is nil" do
      expect { CitruluParser.new.compile_tests(nil) }.to raise_error(ArgumentError)
    end
    
    COMPILER_OUTPUT = [{:test_url=>"http://www.google.com", :tests=>[{:assertion=>:i_see, :value=>"'are you feeling lucky?'"},{:assertion=>:i_not_see, :value=>"'are you feeling Stupid?'"}]}]

    it "should handle input with an initial comment" do
      code = "#this is some code beginning with a comment\nOn http://www.google.com\n  I should see 'are you feeling lucky?'\n  I should not see 'are you feeling Stupid?'"
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
    
    it "should handle input with a comment after the On line" do
      code = "On http://www.google.com\n#a comment after the first line\n  I should see 'are you feeling lucky?'\n  I should not see 'are you feeling Stupid?'"
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
    
    it "should handle input with a comment between two checks" do
      code = "On http://www.google.com\n  I should see 'are you feeling lucky?'\n# this is a comment between two checks \n  I should not see 'are you feeling Stupid?'"
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
    
    it "should handle input with a closing comment" do
      code = "On http://www.google.com\n  I should see 'are you feeling lucky?'\n  I should not see 'are you feeling Stupid?'\n#   ending with a comment  " 
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
  end
end