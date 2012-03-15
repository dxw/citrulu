require "spec_helper"

describe Devise::RegistrationsController do
  describe "routing" do

    it "routes to #settings" do
      get("/settings").should route_to("registrations#edit")
    end

  end
end
