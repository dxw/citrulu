require "spec_helper"

describe TestResultsController do
  describe "routing" do

    it "routes to #index" do
      get("/test_results").should route_to("test_results#index")
    end

    it "routes to #new" do
      get("/test_results/new").should route_to("test_results#new")
    end

    it "routes to #show" do
      get("/test_results/1").should route_to("test_results#show", :id => "1")
    end

    it "routes to #edit" do
      get("/test_results/1/edit").should route_to("test_results#edit", :id => "1")
    end

    it "routes to #create" do
      post("/test_results").should route_to("test_results#create")
    end

    it "routes to #update" do
      put("/test_results/1").should route_to("test_results#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/test_results/1").should route_to("test_results#destroy", :id => "1")
    end

  end
end
