require 'spec_helper'

describe "TestRuns" do
  describe "GET /test_runs" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get test_runs_path
      response.status.should be(302) #redirects because of authentication
    end
  end
end
