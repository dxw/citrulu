require 'spec_helper'

describe "test_groups/new" do
  before(:each) do
    assign(:test_group, stub_model(TestGroup,
      :test_run_id => 1,
      :page_content => "MyText",
      :response_time => 1
    ).as_new_record)
  end

  it "renders new test_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => test_groups_path, :method => "post" do
      assert_select "input#test_group_test_run_id", :name => "test_group[test_run_id]"
      assert_select "textarea#test_group_page_content", :name => "test_group[page_content]"
      assert_select "input#test_group_response_time", :name => "test_group[response_time]"
    end
  end
end
