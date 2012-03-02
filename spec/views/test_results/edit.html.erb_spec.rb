require 'spec_helper'

describe "test_results/edit" do
  before(:each) do
    @test_result = assign(:test_result, stub_model(TestResult,
      :test_group_id => 1,
      :assertion => "MyString",
      :value => "MyString",
      :name => "MyString",
      :result => false
    ))
  end

  it "renders the edit test_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => test_results_path(@test_result), :method => "post" do
      assert_select "input#test_result_test_group_id", :name => "test_result[test_group_id]"
      assert_select "input#test_result_assertion", :name => "test_result[assertion]"
      assert_select "input#test_result_value", :name => "test_result[value]"
      assert_select "input#test_result_name", :name => "test_result[name]"
      assert_select "input#test_result_result", :name => "test_result[result]"
    end
  end
end
