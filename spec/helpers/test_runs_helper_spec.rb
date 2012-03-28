require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the TestRunsHelper. For example:
#
# describe TestRunsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe TestRunsHelper do
  before(:each) do
    @test_run = FactoryGirl.create(:test_run)
    @test_result_name = FactoryGirl.build(:test_result, :name => ":foo_name", :value => nil, :result => true)
    @test_result_value = FactoryGirl.build(:test_result, :value => "foo_value", :name => nil, :result => false)
  end

  describe "ran_tests" do
    it "should return a non-empty string" do
      checks = ran_tests(@test_run)
      
      checks.should be_a(String)
      checks.should_not be_empty
    end
    
    it "should not throw an exception" do
      expect{ran_tests(@test_run)}.to_not raise_error
    end
  end
  
  describe "test_run_path" do
    it "should return a non-empty string" do
      path = test_run_path(@test_run)
      
      path.should be_a(String)
      path.should_not be_empty
    end
    
    it "should not throw an exception" do
      expect{test_run_path(@test_run)}.to_not raise_error
    end
  end

  describe "test_class" do
    it "should return a string" do
      helper.test_class(@test_result_value).should be_a(String)
    end
  end

  describe "value_or_name" do
    it "should say that failed tests failed" do
      helper.value_or_name(@test_result_value).should include("failed")
    end

    describe "values" do
      it "should return plain text if specified" do
        value = helper.value_or_name(@test_result_value, true)
       
        value.should_not include('<')
        value.should_not include('>')
      end

      it "should return the value" do
        helper.value_or_name(@test_result_value).should include("foo_value")
      end

      it "should not return the name" do
        helper.value_or_name(@test_result_value).should_not include(":foo_name")
      end

      it "should include a class" do
        helper.value_or_name(@test_result_value).should include("class=")
      end
    end

    describe "names" do
      before(:each) do
        Predefs.stub(:find).and_return(['foo_a', 'foo_b', 'foo_c'])
      end

      it "should return plain text if specified" do
        value = helper.value_or_name(@test_result_name, true)
       
        value.should_not include('<')
        value.should_not include('>')
      end

      it "should include the name" do
        helper.value_or_name(@test_result_name).should include(":foo_name")
      end

      it "should not include the value" do
        helper.value_or_name(@test_result_name).should_not include("foo_value")
      end

      it "should include the predef values" do
        helper.value_or_name(@test_result_name).should include("foo_a")
        helper.value_or_name(@test_result_name).should include("foo_b")
        helper.value_or_name(@test_result_name).should include("foo_c")
      end
    end
  end
end
