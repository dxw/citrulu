require 'spec_helper'

describe "results/edit" do
  before(:each) do
    @result = assign(:result, stub_model(Result,
      :test_file_id => 1,
      :result => "MyText"
    ))
  end

  it "renders the edit result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => results_path(@result), :method => "post" do
      assert_select "input#result_test_file_id", :name => "result[test_file_id]"
      assert_select "textarea#result_result", :name => "result[result]"
    end
  end
end
