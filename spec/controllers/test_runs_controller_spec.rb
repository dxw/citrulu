require 'spec_helper'

describe TestRunsController do
  login_user
  
  # This should return the minimal set of attributes required to create a valid
  # TestResult. As you add validations to TestResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end
  
  describe "GET index" do
    # it "assigns all test_runs as @test_runs" do
    it "gets the (single) test file from the current user and returns the list of test runs as @test_runs" do
      pending "Integration of the new index page"
      test_run = FactoryGirl.create(:test_run, :test_file => @user.test_files[0])
      get :index
      assigns(:test_runs).should eq([test_run]) 
    end
    
    # Once We've actually implemented test runs....
    it "only shows test runs which belong to the current user" 
  end

  describe "GET show" do
    it "assigns the requested test_run as @test_run" do
      TestRunsController.skip_before_filter :check_ownership!
      test_run = FactoryGirl.create(:test_run)
      get :show, {:id => test_run.id}
      # get :show, {:id => test_run.to_param}
      assigns(:test_run).should eq(test_run)
    end
  end
end
