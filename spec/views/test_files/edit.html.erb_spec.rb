require 'spec_helper'

describe "test_files/edit" do
  before(:each) do
    @test_file = assign(:test_file, stub_model(TestFile))
  end

  it "renders the edit test_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => test_files_path(@test_file), :method => "post" do
    end
  end
end
