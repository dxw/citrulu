require 'spec_helper'

describe CitruluParser do
  describe "compile_tests" do
    it "should raise an exception if the input is nil" do
      expect { CitruluParser.new.compile_tests(nil) }.to raise_error(ArgumentError)
    end
    
    COMPILER_OUTPUT = [
      {:test_url=>"http://www.google.com", 
        :tests=>[
          {:assertion=>:i_see, :original_line =>  "  I should see are you feeling lucky?\n", :value=>"are you feeling lucky?"},
          {:assertion=>:i_not_see, :original_line => "  I should not see are you feeling Stupid?\n", :value=>"are you feeling Stupid?"}
        ]
      }
    ]

    it "should handle input with an initial comment" do
      code = "#this is some code beginning with a comment\nOn http://www.google.com\n  I should see are you feeling lucky?\n  I should not see are you feeling Stupid?"
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
    
    it "should handle input with a comment after the On line" do
      code = "On http://www.google.com\n#a comment after the first line\n  I should see are you feeling lucky?\n  I should not see are you feeling Stupid?"
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
    
    it "should handle input with a comment between two checks" do
      code = "On http://www.google.com\n  I should see are you feeling lucky?\n# this is a comment between two checks \n  I should not see are you feeling Stupid?"
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end
    
    it "should handle input with a closing comment" do
      code = "On http://www.google.com\n  I should see are you feeling lucky?\n  I should not see are you feeling Stupid?\n#   ending with a comment  " 
      CitruluParser.new.compile_tests(code).should == COMPILER_OUTPUT
    end

    it "should understand 'I should see x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")

      code[0][:tests][0][:assertion].should == :i_see
    end

    it "should understand 'I should not see x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should not see x")

      code[0][:tests][0][:assertion].should == :i_not_see
    end

    it "should understand 'Source should contain x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Source should contain x")

      code[0][:tests][0][:assertion].should == :source_contain
    end

    it "should understand 'Source should not contain x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Source should not contain x")

      code[0][:tests][0][:assertion].should == :source_not_contain
    end

    it "should understand 'Headers should include x'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Headers should include x")

      code[0][:tests][0][:assertion].should == :headers_include
    end

    it "should understand 'Headers should not include'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Headers should not include x")

      code[0][:tests][0][:assertion].should == :headers_not_include
    end

   it "should understand values" do
     code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")

     code[0][:tests][0][:value].should == 'x'
     code[0][:tests][0][:name].should == nil
   end
   
   it "should understand names" do
     Predefs.stub(:find).and_return(["a thing", "another thing"])
     code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see :x")

     code[0][:tests][0][:name].should == ':x'
     code[0][:tests][0][:value].should == nil
   end

   it "should not allow nil values" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see") }.to raise_error(CitruluParser::TestCompileError)
   end
   
   it "should not allow empty values" do
     pending "This needs a fix -- the grammar should not permit whitespace to be a valid name"
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see       ") }.to raise_error(CitruluParser::TestCompileError)
   end
   
   it "should not allow nil names" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see :") }.to raise_error(CitruluParser::TestPredefError)
   end
   
   it "should not allow empty names" do
     expect { CitruluParser.new.compile_tests("On http://www.abc.com\n  I should see :      ") }.to raise_error(CitruluParser::TestCompileError)
   end

  end
end
