require 'spec_helper'

describe WebsiteController do
  describe "GET features" do
    before(:each) do
      Plan.stub(:cornichon).and_return(FactoryGirl.create(:plan, number_of_sites: 1))
      Plan.stub(:gherkin).and_return(FactoryGirl.create(:plan, number_of_sites: 2))
      Plan.stub(:cucumber).and_return(FactoryGirl.create(:plan, number_of_sites: 3))
      get :features
    end
    it "Creates and populates @limits" do
      assigns(:limits).should be_a(Array)
      assigns(:limits).first.should be_a(Hash)
    end

    it "Creates and populates @features" do
      assigns(:features).should be_a(Array)
      assigns(:features).first.should be_a(Hash)
    end
    
    it "renders the terms template" do
      response.should render_template("features")
    end
  end
  
  describe "GET terms" do
    it "renders the terms template" do
      get :terms
      response.should render_template("terms")
    end
  end

end
