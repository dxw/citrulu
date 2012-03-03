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
    it "assigns all test_runs as @test_runs" do
      pending "removal of temporary code"
      test_run = FactoryGirl.create(:test_run)
      get :index
      assigns(:test_runs).should eq([test_run])
    end
    
    # Once We've actually implemented test runs....
    it "only shows test runs which belong to the current user" 
  end

  describe "GET show" do
    it "assigns the requested test_run as @test_run" do
      test_run = FactoryGirl.create(:test_run)
      get :show, {:id => test_run.to_param}
      assigns(:test_run).should eq(test_run)
    end
  end

  describe "GET new" do
    it "assigns a new test_run as @test_run" do
      get :new
      assigns(:test_run).should be_a_new(TestRun)
    end
  end

  describe "GET edit" do
    it "assigns the requested test_run as @test_run" do
      test_run = FactoryGirl.create(:test_run)
      get :edit, {:id => test_run.to_param}
      assigns(:test_run).should eq(test_run)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TestRun" do
        expect {
          post :create, {:test_run => valid_attributes}
        }.to change(TestRun, :count).by(1)
      end

      it "assigns a newly created test_run as @test_run" do
        post :create, {:test_run => valid_attributes}
        assigns(:test_run).should be_a(TestRun)
        assigns(:test_run).should be_persisted
      end

      it "redirects to the created test_run" do
        post :create, {:test_run => valid_attributes}
        response.should redirect_to(TestRun.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved test_run as @test_run" do
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        post :create, {:test_run => {}}
        assigns(:test_run).should be_a_new(TestRun)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        post :create, {:test_run => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested test_run" do
        test_run = FactoryGirl.create(:test_run)
        # Assuming there are no other test_runs in the database, this
        # specifies that the TestRun created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TestRun.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => test_run.to_param, :test_run => {'these' => 'params'}}
      end

      it "assigns the requested test_run as @test_run" do
        test_run = FactoryGirl.create(:test_run)
        put :update, {:id => test_run.to_param, :test_run => valid_attributes}
        assigns(:test_run).should eq(test_run)
      end

      it "redirects to the test_run" do
        test_run = FactoryGirl.create(:test_run)
        put :update, {:id => test_run.to_param, :test_run => valid_attributes}
        response.should redirect_to(test_run)
      end
    end

    describe "with invalid params" do
      it "assigns the test_run as @test_run" do
        test_run = FactoryGirl.create(:test_run)
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        put :update, {:id => test_run.to_param, :test_run => {}}
        assigns(:test_run).should eq(test_run)
      end

      it "re-renders the 'edit' template" do
        test_run = FactoryGirl.create(:test_run)
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        put :update, {:id => test_run.to_param, :test_run => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested test_run" do
      test_run = FactoryGirl.create(:test_run)
      expect {
        delete :destroy, {:id => test_run.to_param}
      }.to change(TestRun, :count).by(-1)
    end

    it "redirects to the test_runs list" do
      test_run = FactoryGirl.create(:test_run)
      delete :destroy, {:id => test_run.to_param}
      response.should redirect_to(test_runs_url)
    end
  end

end
