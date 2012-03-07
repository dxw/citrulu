require 'spec_helper'

describe Predefs do
  describe "find" do
    it "Finds predefines which exist" do
    
      test_predef = {:test => [1, 2, 3]}

      Predefs.stub(:predefs).and_return(test_predef)

      Predefs.find("=test").should == test_predef[:test]
    end
  end
end
