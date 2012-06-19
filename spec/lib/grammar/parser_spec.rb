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


    # Comments
    ################

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

    # So I know that 
    ################

    it "should understand So clauses" do
      CitruluParser.new.compile_tests("So I know that everything's OK\nOn http://abc.com\n  I should see x").first[:page][:so].should == "So I know that everything's OK"
    end
    it "should reject So clauses with empty content" do
      expect { CitruluParser.new.compile_tests("So I know that       \nOn http://abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
    end
    it "should reject So clauses with nil content" do
      expect { CitruluParser.new.compile_tests("So I know that\nOn http://abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
    end

    # URLs 
    ################

    it "should understand urls beginning with http://" do
      CitruluParser.new.compile_tests("On http://abc.com\n  I should see x").first[:page][:url].should == "http://abc.com"
    end
    it "should understand urls beginning with https://" do
      CitruluParser.new.compile_tests("On https://abc.com\n  I should see x").first[:page][:url].should == "https://abc.com"
    end
    it "should reject urls without http:// or https://" do
      expect { CitruluParser.new.compile_tests("On www.abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
    end
    it "should reject malformed urls" do
      expect { CitruluParser.new.compile_tests("On htps://abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
      expect { CitruluParser.new.compile_tests("On https:/abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
      expect { CitruluParser.new.compile_tests("On http:abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
      expect { CitruluParser.new.compile_tests("On http:://abc.com\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
    end

    it "should not allow something that doesn't look vaguely like an IPv4 address/non-IDN domain name" do
      expect { CitruluParser.new.compile_tests("On http://  \n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
      expect { CitruluParser.new.compile_tests("On http://\n  I should see x") }.to raise_error(CitruluParser::TestCompileError)
      expect { CitruluParser.new.compile_tests("On http://127.0.0.1:80\n  I should see x") }.to_not raise_error(CitruluParser::TestCompileError)
      expect { CitruluParser.new.compile_tests("On http://example.com\n  I should see x") }.to_not raise_error(CitruluParser::TestCompileError)

      pending "Get somebody who knows how to use treetop to add more strict cases"
    end


    # Response codes 
    ################

    it "should inject an assertion checking for a response code of 200" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")

      code[0][:tests][0][:assertion].should == :response_code_be
      code[0][:tests][0][:value].should == "200"
    end

    it "should not inject an assertion checking for a response code if there is already one there" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x\n  Response code should be 500")

      code[0][:tests][0][:assertion].should == :i_see
    end


    # Simple assertions:
    ################

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

    # Complex assertions:
    ################
    it "should understand 'Header x should contain y'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Header x should contain y")
      test = code.first[:tests][1]
      test[:header]. should == "x"
      test[:assertion].should == :contain
      test[:value].should == "y"
      test[:original_line].should == "Header x should contain y"
    end
    it "should understand 'Header x should not contain y'" do
      code = CitruluParser.new.compile_tests("On http://abc.com\n  Header x should not contain y")
      test = code.first[:tests][1]
      test[:header]. should == "x"
      test[:assertion].should == :not_contain
      test[:value].should == "y"
      test[:original_line].should == "Header x should not contain y"
    end
    
    # HTTP methods:
    ################
    
    shared_examples "an http request" do |method, has_body|
      it "should understand 'When I #{method}' #{' with a body' if has_body}" do
        if has_body
          when_clause = "When I #{method} \"some data\" to http://abc.com"
        else 
          when_clause = "When I #{method} http://abc.com"
        end
        code_group = CitruluParser.new.compile_tests("#{when_clause}\n  I should see x").first
        code_group[:page][:url].should == "http://abc.com"
        code_group[:page][:method].should == method.to_sym
        
        if has_body
          code_group[:page][:data].should == "some data"
        end
      end
    end
    
    it_should_behave_like "an http request", "get", false
    it_should_behave_like "an http request", "head", false
    it_should_behave_like "an http request", "delete", false
    it_should_behave_like "an http request", "put", true
    it_should_behave_like "an http request", "post", true
    
    shared_examples "an invalid http request" do |method, has_body|
      it "should reject 'When I #{method}' #{' with a body' if has_body}" do
        if has_body
          when_clause = "When I #{method} \"some data\" to http://abc.com"
        else 
          when_clause = "When I #{method} http://abc.com"
        end
        expect { CitruluParser.new.compile_tests("#{when_clause}\n  I should see x")}.to raise_error(CitruluParser::TestCompileError)
      end
    end
    
    it_should_behave_like "an invalid http request", "get", true
    it_should_behave_like "an invalid http request", "head", true
    it_should_behave_like "an invalid http request", "delete", true
    it_should_behave_like "an invalid http request", "put", false
    it_should_behave_like "an invalid http request", "post", false
    it_should_behave_like "an invalid http request", "foo", false
    
    
    shared_examples "an incorrectly formatted http request" do |when_clause|
      it "should reject incorrectly formatted http request tests: #{when_clause}" do
        expect { CitruluParser.new.compile_tests("#{when_clause}\n  I should see x")}.to raise_error(CitruluParser::TestCompileError)
      end
    end
    
    it_should_behave_like "an incorrectly formatted http request", "When I post \"some data\" http://abc.com"
    it_should_behave_like "an incorrectly formatted http request", "When I post to http://abc.com"
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
  
  describe "count_checks" do
    it "should return 1 if there is 1 check" do
      # 1 for the check, 1 for the implicit response code check
      object = CitruluParser.new.compile_tests("On http://abc.com\n  I should see x")
      CitruluParser.count_checks(object).should == 1
    end
    it "should return 3 if there are 3 checks on 2 pages" do
      # 3 for the checks, 2 for the implicit response code checks
      test_file_text = "On http://abc.com\n  I should see x\n  Source should contain y\n\nOn http://xyz.co.uk\n  I should see z"
      object = CitruluParser.new.compile_tests(test_file_text)
      CitruluParser.count_checks(object).should == 3
    end
  end
  
  describe "count_domains" do
    # this function removes the repetition from the specs below:
    def domain_count(test_file_text)
      parsed_object = CitruluParser.new.compile_tests(test_file_text)
      CitruluParser.count_domains(parsed_object)
    end
    
    it "should return 1 if there is one domain" do
      domain_count("On http://abc.com\n  I should see x").should == 1
    end
    it "should return 2 if there are two different domains" do
      domain_count("On http://abc.com\n  I should see x\nOn http://xyz.com\n  I should see y").should == 2      
    end
    it "should return 1 if there are two identical urls" do
      domain_count("On http://abc.com\n  I should see x\nOn http://abc.com\n  I should see y").should == 1
    end
    it "should return 1 if there are two different urls with the same domain" do
      domain_count("On http://abc.com\n  I should see x\nOn http://abc.com/login\n  I should see y").should == 1
    end
    it "should return 1 if there are two different urls, one with www, the other without" do
      domain_count("On http://abc.com\n  I should see x\nOn http://www.abc.com\n  I should see y").should == 1
    end
    it "should return 1 if there are two similar urls, one with http the other with https" do
      domain_count("On http://www.abc.com\n  I should see x\nOn https://www.abc.com\n  I should see y").should == 1
    end
    it "should return 1 if there are two similar urls, one with a subdomain" do
      domain_count("On http://www.abc.com\n  I should see x\nOn http://www.xyz.abc.com\n  I should see y").should == 1
    end
    it "should return 2 if there are two similar urls, one with .com, the other with .co.uk" do
      domain_count("On http://www.abc.com\n  I should see x\nOn http://www.abc.co.uk\n  I should see y").should == 2
    end
    
    it "should not count a single invalid URL" do
      domain_count("On http://abcd.asfasfasfasf\n  I should see x").should == 0
    end
    it "should not count an invalid URL in-between valid URLs" do
      domain_count(
        "On http://abcd.com\n  I should see x\n" +
        "On http://abcd.asfasfasfasf\n  I should see x\n" +
        "On http://abcd.co.uk\n  I should see x"
        ).should == 2
    end
    
    it "should return 2 in a complex example :-)" do
      domain_count(
        #These should all count as 1:
        "On http://www.d23.ef9.abc.com\n  I should see x\nOn https://www.xyz.abc.com\n  I should see y\n" +
        #These should be ignored:
        "On http://abcd.asfass\n  I should see x\n" +
        #These should all count as 1:
        "On http://abc.co.uk\n  I should see x\nOn http://abc.co.uk\n  I should see y\n" +
        #This is different - should count as 1:
        "On http://abc.foo.co.uk\n  I should see x"      
      ).should == 3
    end
  end
end
