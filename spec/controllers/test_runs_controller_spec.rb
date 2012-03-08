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
    it "should define @test_files" do
      get :index
      assigns(:test_files).should be_an(Array) 
    end
    it "should define @test_runs" do
      get :index
      assigns(:test_runs).should be_an(Array) 
    end

    it "should define @recent_failed_test_groups" do
      get :index
      assigns(:recent_failed_groups).should be_an(Array) 
    end
    
    it "should render the index template" do
      get :index

      response.should render_template("index")
    end

    it "only shows test runs which belong to the current user" do 
      another_user = FactoryGirl.create(:user)

      get :index

      file_users = assigns(:test_files).collect{|f| f.user_id}.uniq

      file_users.should have(1).items
      file_users.first.should == controller.current_user.id
    end
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
