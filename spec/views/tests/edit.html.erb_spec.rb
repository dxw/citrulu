require 'spec_helper'

describe "tests/edit" do
  before(:each) do
    @test = assign(:test, stub_model(Test,
      :test_group_id => 1,
      :assertion => "MyString",
      :value => "MyString",
      :name => "MyString",
      :result => false
    ))
  end

  it "renders the edit test form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tests_path(@test), :method => "post" do
      assert_select "input#test_test_group_id", :name => "test[test_group_id]"
      assert_select "input#test_assertion", :name => "test[assertion]"
      assert_select "input#test_value", :name => "test[value]"
      assert_select "input#test_name", :name => "test[name]"
      assert_select "input#test_result", :name => "test[result]"
    end
  end
end
