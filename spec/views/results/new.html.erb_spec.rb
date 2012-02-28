require 'spec_helper'

describe "results/new" do
  before(:each) do
    assign(:result, stub_model(Result,
      :test_file_id => 1,
      :result => "MyText"
    ).as_new_record)
  end

  it "renders new result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => results_path, :method => "post" do
      assert_select "input#result_test_file_id", :name => "result[test_file_id]"
      assert_select "textarea#result_result", :name => "result[result]"
    end
  end
end
