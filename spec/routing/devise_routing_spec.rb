require "spec_helper"

describe Devise::RegistrationsController do
  describe "routing" do

    it "routes to #settings" do
      get("/settings").should route_to("devise/registrations#edit")
    end

    # DGMS, passes - not 100% sure it's testing the right thing:
    # By default, after updating, devise will redirect to the "signed_in_root_path" 
    # (in our case test_files#index), but we want it to stay on the edit page
    it "routes back to edit page after #upate" do
      get('users').should route_to("devise/registrations#edit")
    end
  end
end
