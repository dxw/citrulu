require 'spec_helper'

describe WebsiteController do
  describe "GET features" do
    it "Creates and populates @limits" do
      get :features

      assigns(:limits).should be_a(Array)
      assigns(:limits).first.should be_a(Hash)
    end

    it "Creates and populates @features" do
      get :features

      assigns(:features).should be_a(Array)
      assigns(:features).first.should be_a(Hash)
    end
  end

end
