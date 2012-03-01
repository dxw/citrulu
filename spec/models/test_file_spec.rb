require 'spec_helper'

describe TestFile do
  describe "compile_tests" do
    it "should understand 'I should see x'" do
      code = TestFile.compile_tests("On http://abc.com\n  I should see x")

      code[0][:tests][0][:assertion].should == :i_see
    end

    it "should understand 'I should not see x'" do
      code = TestFile.compile_tests("On http://abc.com\n  I should not see x")

      code[0][:tests][0][:assertion].should == :i_not_see
    end

    it "should understand 'Source should contain x'" do
      code = TestFile.compile_tests("On http://abc.com\n  Source should contain x")

      code[0][:tests][0][:assertion].should == :source_contain
    end

    it "should understand 'Source should not contain x'" do
      code = TestFile.compile_tests("On http://abc.com\n  Source should not contain x")

      code[0][:tests][0][:assertion].should == :source_not_contain
    end

    it "should understand 'Headers should include x'" do
      code = TestFile.compile_tests("On http://abc.com\n  Headers should include x")

      code[0][:tests][0][:assertion].should == :headers_include
    end

    it "should understand 'Headers should not include'" do
      code = TestFile.compile_tests("On http://abc.com\n  Headers should not include x")

      code[0][:tests][0][:assertion].should == :headers_not_include
    end

   it "should understand values" do
     code = TestFile.compile_tests("On http://abc.com\n  I should see x")

     code[0][:tests][0][:value].should == 'x'
     code[0][:tests][0][:name].should == nil
   end

   it "should understand names" do
     code = TestFile.compile_tests("On http://abc.com\n  I should see =x")

     code[0][:tests][0][:name].should == '=x'
     code[0][:tests][0][:value].should == nil
   end

    it "should understand URLs" do
      code = TestFile.compile_tests("On http://www.abc.com\n  I should see x")

      code[0][:test_url].should == 'http://www.abc.com'
    end
      
  end    
end
