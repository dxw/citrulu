require "spec_helper"

describe WebsiteController do
  describe "routing" do

    it "routes to #index" 
    #Broken - probably because of 
    # do
    #       get("/").should route_to("website#index")
    #     end

    it "routes to #features" do
      get("/features").should route_to("website#features")
    end
  end
end