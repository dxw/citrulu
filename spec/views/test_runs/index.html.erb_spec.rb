require 'spec_helper'

describe "test_runs/index" do
  before(:each) do
    assign(:test_runs, [
      stub_model(TestRun,
        :test_file_id => 1
      ),
      stub_model(TestRun,
        :test_file_id => 1
      )
    ])
  end

  it "renders a list of test_runs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
