require "spec_helper"

describe TestsController do
  describe "routing" do

    it "routes to #index" do
      get("/tests").should route_to("tests#index")
    end

    it "routes to #new" do
      get("/tests/new").should route_to("tests#new")
    end

    it "routes to #show" do
      get("/tests/1").should route_to("tests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/tests/1/edit").should route_to("tests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/tests").should route_to("tests#create")
    end

    it "routes to #update" do
      put("/tests/1").should route_to("tests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/tests/1").should route_to("tests#destroy", :id => "1")
    end

  end
end
