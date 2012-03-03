require "spec_helper"

describe TestGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/test_groups").should route_to("test_groups#index")
    end

    it "routes to #new" do
      get("/test_groups/new").should route_to("test_groups#new")
    end

    it "routes to #show" do
      get("/test_groups/1").should route_to("test_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/test_groups/1/edit").should route_to("test_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/test_groups").should route_to("test_groups#create")
    end

    it "routes to #update" do
      put("/test_groups/1").should route_to("test_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/test_groups/1").should route_to("test_groups#destroy", :id => "1")
    end

  end
end
