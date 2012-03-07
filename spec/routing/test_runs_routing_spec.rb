require "spec_helper"

describe TestRunsController do
  describe "routing" do

    it "routes to #index" do
      get("/test_runs").should route_to("test_runs#index")
    end

    it "routes to #show" do
      get("/test_runs/1").should route_to("test_runs#show", :id => "1")
    end

  end
end
