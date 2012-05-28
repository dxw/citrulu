require 'spec_helper'
describe TestFilesController do
  login_user
  
  # This should return the minimal set of attributes required to create a valid
  # TestResult. As you add validations to TestResult, be sure to
  # update the return value of this method accordingly.
  def valid_update_attributes
    {"test_file_text" => "this is some new text"}
  end
  
  def valid_create_attributes
    FactoryGirl.build(:test_file).attributes
  end
  
  before(:each) do
    @test_file = FactoryGirl.create(:test_file)
    
    # For ownership checks: create another user with their own test file
    other_user = FactoryGirl.create(:user)
    @other_test_file = FactoryGirl.create(:test_file, :user => other_user)
  end  
  
  describe "GET index" do
    it "should create @test_files" do
      get :index

      assigns(:test_files).should be_a(Array)
    end
    
    it "should create @recent_failed_groups" do
      get :index

      assigns(:recent_failed_pages).should be_an(Integer)
      assigns(:recent_failed_assertions).should be_an(Integer)
    end
  end


  describe "POST create" do
    it "creates a new TestFile" do
      expect {
        post :create
      }.to change(TestFile, :count).by(1)
    end
    
    it "sets the current user as the new test_file's owner " do
      post :create
      TestFile.find(assigns(:test_file).id).user.should == @user
    end

    it "redirects to the editor with 'new=true'" do
      post :create
      response.should redirect_to(edit_test_file_path(TestFile.last)+'?new=true')
    end
  end
  
  

  describe "GET edit" do
    it "assigns the requested test_file as @test_file" do
      controller.stub(:check_ownership!)
      get :edit, {:id => @test_file.to_param}
      assigns(:test_file).should eq(@test_file)
    end
    
    it "checks ownership of the test file" do
      get :edit, {:id => @other_test_file.to_param}
      response.should redirect_to(:controller => "test_files", :action => "index")
    end
  end
  
  
  describe "PUT update" do
    def successful_update
      assigns(:console_msg_type).should == "success"
    end
    
    def failed_update
      assigns(:console_msg_type).should == "error"
    end
    
    it "checks ownership of the test file" do
      put :update, {:id => @other_test_file.to_param, :test_file => valid_update_attributes}
      response.should redirect_to(:controller => "test_files", :action => "index")
    end
    
    
    describe "with valid params" do
      before(:each) do
        controller.stub(:check_ownership!)
      end
      
      it "updates the requested test_file" do
        # Assuming there are no other test_files in the database, this
        # specifies that the TestFile created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TestFile.any_instance.should_receive(:update_attributes).with(valid_update_attributes)
        put :update, {:id => @test_file.to_param, :test_file => valid_update_attributes}
        # DGMS - Not sure if the above is correct... here's the scaffold:
        # TestFile.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        # put :update, {:id => test_file.to_param, :test_file => {'these' => 'params'}}
      end
  
      it "assigns the requested test_file as @test_file" do
        put :update, {:id => @test_file.to_param, :test_file => valid_update_attributes}
        assigns(:test_file).should eq(@test_file)
      end
      
      it "handles a test file with nil text" do
        TestFile.any_instance.should_receive(:update_attributes).with("test_file_text" => nil)
        put :update, {:id => @test_file.to_param, :test_file => valid_update_attributes.merge({"test_file_text" => nil})}
        successful_update
      end
      
      it "handles a test file with empty text" do
        TestFile.any_instance.should_receive(:update_attributes).with("test_file_text" => "")
        put :update, {:id => @test_file.to_param, :test_file => valid_update_attributes.merge({"test_file_text" => ""})}
        successful_update
      end
    end
  
    describe "with invalid params" do
      before(:each) do
        controller.stub(:check_ownership!)
      end
      
      it "assigns the test_file as @test_file" do
        # Trigger the behavior that occurs when invalid params are submitted
        TestFile.any_instance.stub(:save).and_return(false)
        put :update, {:id => @test_file.to_param, :test_file => {}}
        assigns(:test_file).should eq(@test_file)
      end
    end
    
    context "when a compilation error is raised" do 
      before(:each) do
        controller.stub(:check_ownership!)
        @new_test_file_params = {:test_file_text => "foo"}
      end
      
      context "because the input was invalid" do
        it "raises an appropriate error message" do
          put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => "foo"}}

          #These should maybe be split out into seperate tests?
          assigns(:console_msg_hash)[:text1].should include "Compilation failed"
          assigns(:console_msg_hash)[:expected].should include "#"
          assigns(:console_msg_hash)[:line].should == "1"
          assigns(:console_msg_hash)[:column].should == "1"
        end
        
        context "and the error could not be formatted" do
          before(:each) do 
            CitruluParser.any_instance.stub(:format_error).and_raise("foo")
          end
          it "raises an appropriate error message" do
            pending
            put :update, {:id => @test_file.to_param, :test_file => @new_test_file_params}
            # Check for the error:
          end
        end
      end
      
      context "because of an unknown error" do
        before(:each) do 
          CitruluParser.any_instance.stub(:compile_tests).and_raise(CitruluParser::TestCompileUnknownError.new("foo"))
          @new_test_file_params = {:test_file_text => "foo"}
        end
        
        it "raises an appropriate error message" do
          pending
          put :update, {:id => @test_file.to_param, :test_file => @new_test_file_params}
          # Check for the error:
        end  
      end
      
      context "because of a predef error" do
        it "raises an appropriate error message"
      end
      
    end
    
    describe "shouldn't try and compile" do
      before(:each) do
        CitruluParser.any_instance.should_not_receive(:compile_tests)
        controller.stub(:check_ownership!) 
      end
      it "if the code is empty" do
        put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => ""}}  
      end
      it "if the code is nil" do
        put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => nil}} 
      end
    end
  end

  describe "PUT update_run_status" do
    context "when the current status is run_tests=true" do
      before(:each) do
        @test_file = FactoryGirl.create(:test_file, run_tests: true)
      end
      
      it "doesn't redirect" do
        put :update_run_status, {:id => @test_file.to_param, :test_file => {run_tests: false}}
        response.should_not be_redirect
      end
      
      it "changes the status to run_tests=false when the button is pressed" do
        TestFile.any_instance.should_receive(:update_attributes).with(run_tests: false)
        put :update_run_status, {:id => @test_file.to_param, :test_file => {run_tests: false}}
      end
    end
    
    context "when the current status is run_tests=false" do
      before(:each) do
        @test_file = FactoryGirl.create(:test_file, run_tests: false)
      end
      
      it "doesn't redirect" do
        put :update_run_status, {:id => @test_file.to_param, :test_file => {run_tests: true}}
        response.should_not be_redirect
      end
      
      it "changes the status to run_tests=false when the button is pressed" do
        TestFile.any_instance.should_receive(:update_attributes).with(run_tests: true)
        put :update_run_status, {:id => @test_file.to_param, :test_file => {run_tests: true}}
      end
    end
  end
  
  describe "POST create_first_test_file" do
  
  end

#
#  Commented out, along with the delete method, until we actually need it
#
#  describe "DELETE destroy" do
#    before (:each) do
#      TestFilesController.skip_before_filter :check_ownership!
#    end
#    
#    it "destroys the requested test_file" do 
#      test_file = FactoryGirl.create(:test_file)
#      expect {
#        delete :destroy, {:id => test_file.to_param}
#      }.to change(TestFile, :count).by(-1)
#    end
#  
#    it "redirects to the test_files list" do
#      test_file = FactoryGirl.create(:test_file)
#      delete :destroy, {:id => test_file.to_param}
#      response.should redirect_to(test_files_url)
#    end
#
#    it "checks ownership of the test file" do
#      delete :destroy, {:id => @other_test_file.to_param}
#      response.should redirect_to(:controller => "test_files", :action => "index")
#    end
#  end

end
