require 'spec_helper'

describe "test_results/show" do
  before(:each) do
    @test_result = assign(:test_result, stub_model(TestResult,
      :test_group_id => 1,
      :assertion => "Assertion",
      :value => "Value",
      :name => "Name",
      :result => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Assertion/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Value/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
