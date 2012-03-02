require 'spec_helper'

describe "test_results/new" do
  before(:each) do
    assign(:test_result, stub_model(TestResult,
      :test_group_id => 1,
      :assertion => "MyString",
      :value => "MyString",
      :name => "MyString",
      :result => false
    ).as_new_record)
  end

  it "renders new test_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => test_results_path, :method => "post" do
      assert_select "input#test_result_test_group_id", :name => "test_result[test_group_id]"
      assert_select "input#test_result_assertion", :name => "test_result[assertion]"
      assert_select "input#test_result_value", :name => "test_result[value]"
      assert_select "input#test_result_name", :name => "test_result[name]"
      assert_select "input#test_result_result", :name => "test_result[result]"
    end
  end
end
