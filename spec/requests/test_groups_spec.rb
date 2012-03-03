require 'spec_helper'

# not working - error: undefined method `model_name' for NilClass:Class
# I think this is to do with the @test_groups object being nil where it shouldn't be, but I didn't manage to get any further.
# DGMS 03/03/2012

# describe "TestGroups" do
#   describe "GET /test_groups" do
#     it "works! (now write some real specs)" do
#       # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#       get test_groups_path
#       response.status.should be(200)
#     end
#   end
# end
