require 'spec_helper'

describe "test_files/index" do
  before(:each) do
    assign(:test_files, [
      stub_model(TestFile),
      stub_model(TestFile)
    ])
  end

  it "renders a list of test_files" do
    render
  end
end
