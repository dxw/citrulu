require 'spec_helper'

describe "test_runs/index" do
  before(:each) do
    assign(:test_runs, [
      FactoryGirl.create(:test_run),
      FactoryGirl.create(:test_run)
    ])
    render
  end

  it "renders a list of test_runs" do
    assert_select "ul#test_runs_list li", :count => 2
  end
end
