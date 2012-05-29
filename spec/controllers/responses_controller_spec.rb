require 'spec_helper'
describe ResponsesController do
  login_user
  
  describe "GET show" do
    before(:each) do
      @myresponse = FactoryGirl.create(:response)
    end
    
    context "when the response is owned by the user" do
      before(:each) do
        controller.stub(:check_ownership!)
      end
    
      it "should set @response" do
        get :show, {:id => @myresponse.to_param}
        assigns(:response).should eq(@myresponse)
      end
    
      it "should render responses/show" do
        get :show, {:id => @myresponse.to_param}
        response.should render_template('show')
      end
    end
    
    it "checks ownership of the response" do
      other_user = FactoryGirl.create(:user)
      other_test_file = FactoryGirl.create(:test_file, user: other_user)
      other_test_run = FactoryGirl.create(:test_run, test_file: other_test_file)
      other_response = FactoryGirl.create(:response)
      other_test_group = FactoryGirl.create(:test_group, test_run: other_test_run, response: other_response)
      
      get :show, {:id => other_response.to_param}
      response.should redirect_to(:controller => "test_runs", :action => "index")
    end
  end
end
