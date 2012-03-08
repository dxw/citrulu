require "spec_helper"

describe TestFilesController do
  describe "routing" do

    it "routes to #index" do
      get("/test_files").should route_to("test_files#index")
    end

    it "routes to #edit" do
      get("/test_files/1/edit").should route_to("test_files#edit", :id => "1")
    end

    it "routes to #update" do
      put("/test_files/1").should route_to("test_files#update", :id => "1")
    end

  end
end
