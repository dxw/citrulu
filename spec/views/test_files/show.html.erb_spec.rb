require 'spec_helper'

describe "test_files/show" do
  before(:each) do
    @test_file = assign(:test_file, stub_model(TestFile))
  end

  it "renders attributes in <p>" do
    render
  end
end
