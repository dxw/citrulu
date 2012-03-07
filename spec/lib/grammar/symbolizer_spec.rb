require 'spec_helper'

describe "Symbolizer" do
  describe "String" do
    describe ".to_test_sym" do
      it "converts a string to a symbol" do
        "Source should contain".to_test_sym.should == :source_contain
      end
    end
  
    describe ".to_test_s" do 
      it "converts a test string to a formatted string" do
        "source_contain".to_test_s.should == "Source should contain"
      end
    end
  end
  
  describe "Symbol" do
    describe ".to_test_s" do
      it "converts a symbol to a string" do
        :source_contain.to_test_s.should ==  "Source should contain"
      end
    end
  end
end