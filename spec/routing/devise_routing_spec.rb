require "spec_helper"

describe Devise::RegistrationsController do
  describe "routing" do

    it "routes to #settings" do
      pending "can't get this to work"
      get("/settings").should route_to("registrations#edit")
    end

  end
end
