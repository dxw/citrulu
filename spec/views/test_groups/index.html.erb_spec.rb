# require 'spec_helper'
# 
# describe "test_groups/index" do
#   before(:each) do
#     assign(:test_groups, [
#       stub_model(TestGroup,
#         :test_run_id => 1,
#         :page_content => "MyText",
#         :response_time => 1
#       ),
#       stub_model(TestGroup,
#         :test_run_id => 1,
#         :page_content => "MyText",
#         :response_time => 1
#       )
#     ])
#   end
# 
#   it "renders a list of test_groups" do
#     render
#     # Run the generator again with the --webrat flag if you want to use webrat matchers
#     assert_select "tr>td", :text => 1.to_s, :count => 2
#     # Run the generator again with the --webrat flag if you want to use webrat matchers
#     assert_select "tr>td", :text => "MyText".to_s, :count => 2
#     # Run the generator again with the --webrat flag if you want to use webrat matchers
#     assert_select "tr>td", :text => 1.to_s, :count => 2
#   end
# end
