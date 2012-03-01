require 'spec_helper'

describe "test_runs/show" do
  before(:each) do
    @test_run = assign(:test_run, stub_model(TestRun,
      :test_file_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
