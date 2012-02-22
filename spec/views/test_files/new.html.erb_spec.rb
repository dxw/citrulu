require 'spec_helper'

describe "test_files/new" do
  before(:each) do
    assign(:test_file, stub_model(TestFile).as_new_record)
  end

  it "renders new test_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => test_files_path, :method => "post" do
    end
  end
end
