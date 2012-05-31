require 'spec_helper'

describe CitruluParser do
  describe "compile_tests" do
    it "should raise an exception if the input is nil" do
      expect { CitruluParser.new.compile_tests(nil) }.to raise_error(ArgumentError)
    end
    
    context "when the parser returns nil" do
      before(:each) do
        CitruluParser.any_instance.stub(:parse)
      end
      it "should raise an Unknown exception if the failure reason was nil" do
        CitruluParser.any_instance.stub(:failure_reason).and_return(nil)
        expect { CitruluParser.new.compile_tests("foo") }.to raise_error(CitruluParser::TestCompileUnknownError) 
      end
      it "should raise a compile error if the failure reason was not nill" do
        CitruluParser.any_instance.stub(:failure_reason).and_return("A failure reason")
        expect { CitruluParser.new.compile_tests("foo") }.to raise_error(CitruluParser::TestCompileError, /A failure reason/)
      end
    end
    
    
    COMPILER_OUTPUT_TESTS = [
      {:assertion=>:response_code_be, :value=>"200", :original_line=>"Response code should be 200 after redirects", :value=>"200"},
      {:assertion=>:i_see, :original_line =>  "I should see are you feeling lucky?", :value=>"are you feeling lucky?"},
      {:assertion=>:i_not_see, :original_line => "I should not see are you feeling Stupid?", :value=>"are you feeling Stupid?"}
    ]
      

    it "should handle input with an initial comment" do
      code = "#this is some code beginning with a comment\nOn http://www.google.com\n  I should see are you feeling lucky?\n  I should not see are you feeling Stupid?"
      CitruluParser.new.compile_tests(code).first[:tests].should == COMPILER_OUTPUT_TESTS
    end
    
    it "should handle input with a comment after the On line" do
      code = "On http://www.google.com\n#a comment after the first line\n  I should see are you feeling lucky?\n  I should not see are you feeling Stupid?"
      CitruluParser.new.compile_tests(code).first[:tests].should == COMPILER_OUTPUT_TESTS
    end
    
    it "should handle input with a comment between two checks" do
      code = "On http://www.google.com\n  I should see are you feeling lucky?\n# this is a comment between two checks \n  I should not see are you feeling Stupid?"
      CitruluParser.new.compile_tests(code).first[:tests].should == COMPILER_OUTPUT_TESTS
    end
    
    it "should handle input with a closing comment" do
      code = "On http://www.google.com\n  I should see are you feeling lucky?\n  I should not see are you feeling Stupid?\n#   ending with a comment  " 
      CitruluParser.new.compile_tests(code).first[:tests].should == COMPILER_OUTPUT_TESTS
    end
    
    it "should inject an assertion checking for a response code of 200" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")

      code[0][:tests][0][:assertion].should == :response_code_be
      code[0][:tests][0][:value].should == "200"
    end
    
    it "should not inject an assertion checking for a response code if there is already one there" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x\n  Response code should be 500")

      code[0][:tests][0][:assertion].should == :i_see
    end
    
    it "should understand 'I should see x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")

      code[0][:tests][1][:assertion].should == :i_see
    end

    it "should understand 'I should not see x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should not see x")

      code[0][:tests][1][:assertion].should == :i_not_see
    end

    it "should understand 'Source should contain x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Source should contain x")

      code[0][:tests][1][:assertion].should == :source_contain
    end

    it "should understand 'Source should not contain x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Source should not contain x")

      code[0][:tests][1][:assertion].should == :source_not_contain
    end

    it "should understand 'Headers should include x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Headers should include x")

      code[0][:tests][1][:assertion].should == :headers_include
    end

    it "should understand 'Headers should not include'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Headers should not include x")

      code[0][:tests][1][:assertion].should == :headers_not_include
    end

   it "should understand values" do
     code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")

     code[0][:tests][1][:value].should == 'x'
     code[0][:tests][1][:name].should == nil
   end
   
   it "should understand names" do
     Predefs.stub(:find).and_return(["a thing", "another thing"])
     code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see :x")

     code[0][:tests][1][:name].should == ':x'
     code[0][:tests][1][:value].should == nil
   end

   it "should not allow nil values" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see") }.to raise_error(CitruluParser::TestCompileError)
   end
   
   it "should not allow empty values" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see       ") }.to raise_error(CitruluParser::TestCompileError)
   end
   
   it "should not allow nil names" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see :") }.to raise_error(CitruluParser::TestPredefError)
   end
   
   it "should not allow empty names" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see :      ") }.to raise_error(CitruluParser::TestCompileError)
   end

   it "should not allow something that doesn't look vaguely like an IPv4 address/non-IDN domain name" do
     pending "Get somebody who knows how to use treetop to do this"
     expect { CitruluParser.new.compile_tests("On http://  \n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
     expect { CitruluParser.new.compile_tests("On http://\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
     expect { CitruluParser.new.compile_tests("On http://127.0.0.1:80\n  I should see x") }.to_not raise_error(CitruluParser::TestCompileError)
     expect { CitruluParser.new.compile_tests("On http://example.com\n  I should see x") }.to_not raise_error(CitruluParser::TestCompileError)
   end

  end
  
  describe "parse_error" do
    it "should match an error with 'Line' at the beginning" do
      error = "Line 1: Expected one of #, So I know that, On, When I at line 1, column 1 (byte 1) after"
      CitruluParser.parse_error(error).should_not be_blank
    end
  end
  
  describe "format_error" do
    before(:each) do
      @match_string = [0,1,2,3,"expected_thing",5,"linenum","columnnum",8,"aftermsg"]
    end
    
    it "should raise an exception if the error format was not recognised" do
      CitruluParser.stub(:parse_error) #so returns nil
      expect { CitruluParser.format_error("bar") }.to raise_error(ArgumentError)
    end
    
    context "when processing the 'after' part" do
      it "should convert ' ' into 'a space" do
        @match_string[9] = ' '
        CitruluParser.stub(:parse_error).and_return(@match_string)
        CitruluParser.format_error("bar")[:after].should == "a space"
      end
      it "should convert \n into 'a newline" do
        @match_string[9] = "\n" 
        CitruluParser.stub(:parse_error).and_return(@match_string)
        CitruluParser.format_error("bar")[:after].should == "a newline"
      end
      it "should add quotes around non- whitespace strings" do
        CitruluParser.stub(:parse_error).and_return(@match_string)
        CitruluParser.format_error("bar")[:after].should == "'aftermsg'"
      end
      
    end    
  end
end
