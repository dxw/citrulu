require 'spec_helper'

describe "tests/index" do
  before(:each) do
    assign(:tests, [
      stub_model(Test,
        :test_group_id => 1,
        :assertion => "Assertion",
        :value => "Value",
        :name => "Name",
        :result => false
      ),
      stub_model(Test,
        :test_group_id => 1,
        :assertion => "Assertion",
        :value => "Value",
        :name => "Name",
        :result => false
      )
    ])
  end

  it "renders a list of tests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Assertion".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Value".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
