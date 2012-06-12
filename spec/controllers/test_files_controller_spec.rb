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
    @test_file = FactoryGirl.create(:test_file, user: @user)
    
    # For ownership checks: create another user with their own test file
    other_user = FactoryGirl.create(:user)
    @other_test_file = FactoryGirl.create(:test_file, :user => other_user)
  end  
  
  describe "GET index" do
    it "should create @test_files" do
      get :index
      
      assigns(:test_files).should be_an(ActiveRecord::Relation)
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
    
    it "should fire a google analytics event if this is the first created file" do
      # @user should be fresh so won't have a created test file, but let's double-check:
      UserMeta.where(user_id: @user.to_param).should be_empty
      
      controller.should_receive(:log_event).with("Test Files", "Created test file")
      post :create
    end
    
    it "should NOT fire a google analytics event if this is not the first created file" do
      post :create
      controller.should_not_receive(:log_event).with("Test Files", "Created test file")
      post :create
    end
  end
  
  
  describe "POST create_first_test_file" do
    it "should assign @test_file" do
      User.any_instance.should_receive(:create_first_test_file).and_return(@test_file)
      post :create_first_test_file
    end
    
    it "should redirect to the editor with 'new=true'" do
      post :create_first_test_file
      response.should redirect_to(edit_test_file_path(TestFile.last)+'?new=true')
    end
    
    it "should fire a google analytics event if this is the first created file" do
      # @user should be fresh so won't have a created test file, but let's double-check:
      UserMeta.where(user_id: @user.to_param).should be_empty
      
      controller.should_receive(:log_event).with("Test Files", "Created test file")
      post :create
    end
    
    it "should NOT fire a google analytics event if this is not the first created file" do
      post :create
      controller.should_not_receive(:log_event).with("Test Files", "Created test file")
      post :create
    end
  end

  describe "GET edit" do
    it "assigns the requested test_file as @test_file" do
      controller.stub(:check_ownership!)
      get :edit, {:id => @test_file.to_param}
      assigns(:test_file).should eq(@test_file)
    end
    
    context "when the test file is a tutorial" do
      before(:each) do
        @test_file.update_attribute(:tutorial_id, 1)
        get :edit, {:id => @test_file.to_param}
      end
      it "should assign an array of strings to @help_texts" do
        assigns(:help_texts).should be_an(Array)
        assigns(:help_texts).first.should be_a(String)
      end
      it "should assign @help_shown" do
        assigns(:help_shown).should be_an(Integer)
      end
    end
    
    it "checks ownership of the test file" do
      get :edit, {:id => @other_test_file.to_param}
      response.should redirect_to(:controller => "test_files", :action => "index")
    end
  end
  
  describe "POST update_liveview" do
    context "when there are no errors" do      
      it "should assign @current_line from params" do
        post :update_liveview, {:id => @other_test_file.to_param, :current_line => 2}
        assigns(:current_line).should == "2"
      end
      
      it "should call execute_tests and assign the result @results" do
        CitruluParser.any_instance.stub(:compile_tests)
        TestRunner.stub(:execute_tests).and_return(["result"])
        
        post :update_liveview, {:id => @other_test_file.to_param, group: "foo"}
        assigns(:results).should == "result"
      end
    end
    
    context "when a compilation error is thrown" do
      before(:each) do
        CitruluParser.any_instance.stub(:compile_tests).and_raise(CitruluParser::TestCompileError.new("comp error"))
        @error_message = {
          expected_arr: [],
          line: 1,
          column: 1,
        }
      end
      it "should assign @error" do
        CitruluParser.stub(:format_error).and_return(@error_message)
        post :update_liveview, {:id => @other_test_file.to_param, group: "foo"}
        assigns(:error).should be_a(Hash)
      end
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
        CitruluParser.any_instance.stub(:compile_tests).and_raise(CitruluParser::TestCompileError.new("foo"))
      end
      
      context "and the error can be formatted" do
        before(:each) do
          CitruluParser.stub(:format_error).and_return({:after => "x"})
          put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => "some text"}}
        end
        it "should set error messages" do
          assigns(:console_msg_type).should == "error"
          assigns(:status_msg).should == "Saved (with errors)"
        end
      
        it "raises an appropriate console message" do
          assigns(:console_msg_hash)[:text1].should include "Compilation failed"
        end
      end
      
      context "and the error could not be formatted" do
        before(:each) do
          CitruluParser.stub(:format_error).and_raise("a format error")
          put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => "some text"}}
        end
        it "should set error messages" do
          assigns(:console_msg_type).should == "error"
          assigns(:status_msg).should == "Saved (with errors)"
        end
        
        it "raises an appropriate console message" do
          #These should maybe be split out into seperate tests?
          assigns(:console_msg_hash)[:text1].should include "Something has gone wrong"
        end
      end
    end
    
      
    context "when a predef error is raised" do
      before(:each) do 
        CitruluParser.any_instance.stub(:compile_tests).and_raise(CitruluParser::TestPredefError.new("foo"))
        put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => "foo"}}
      end
      it "should set error messages" do
        assigns(:console_msg_type).should == "error"
        assigns(:status_msg).should == "Saved (with errors)"
      end
      
      it "should assign @console_msg_hash" do
        assigns(:console_msg_hash).should be_a(Hash)
        assigns(:console_msg_hash).should_not be blank?
      end
    end
      
    context "when an unknown error is raised" do
      before(:each) do 
        CitruluParser.any_instance.stub(:compile_tests).and_raise(CitruluParser::TestCompileUnknownError.new("foo"))
        put :update, {:id => @test_file.to_param, :test_file => {:test_file_text => "foo"}}
        @new_test_file_params = {:test_file_text => "foo"}
      end
      
      it "should set error messages" do
        assigns(:console_msg_type).should == "error"
        assigns(:status_msg).should == "Saved (with errors)"
      end

      it "should assign @console_msg_hash" do
        assigns(:console_msg_hash).should be_a(Hash)
        assigns(:console_msg_hash).should_not be blank?
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

  describe "PUT update_name" do
    before(:each) do
      @new_name = "New Name"
    end
    
    after(:each) do 
      put :update_name,  {:id => @test_file.to_param, :test_file => {name: @new_name}}
    end
    
    context "when the name is not taken" do
      it "should assign that name" do
        TestFile.any_instance.should_receive(:name=).with(@new_name)
      end
      
      it "should save the test file" do
        TestFile.any_instance.should_receive(:save)
      end
      
    end
    
    context "when the name is taken" do
      before(:each) do
        FactoryGirl.create(:test_file, name: @new_name, user: @user)
      end
      it "should generate a different name" do
        User.any_instance.should_receive(:generate_name).with(@new_name).and_return("foo") 
      end
      
      it "should assign a new name to the test_file" do
        TestFile.any_instance.should_receive(:name=)
        # 'should_recieve' means that the function doesn't actually execute,
        # so we need to simulate the validation failure: 
        TestFile.any_instance.stub(:save).and_return(false)
        User.any_instance.stub(:generate_name).and_return("foo123")
        
        # Second assignment:
        TestFile.any_instance.should_receive(:name=).with("foo123")
      end
      
      it "should save the test file" do
        TestFile.any_instance.should_receive(:save!)
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
  

  describe "DELETE destroy" do
    context "when the file belongs to the user" do
      before (:each) do
        TestFilesController.stub(:check_ownership!)
      end
    
      it "Calls 'delete!' on the model" do
        TestFile.any_instance.should_receive(:delete!)
        delete :destroy, :id => @test_file.to_param, :format => 'js'
      end

      it "renders the destroy (js) template" do
        delete :destroy, :id => @test_file.to_param, :format => 'js'
        response.should render_template("destroy")
      end
    end

    it "checks ownership of the test file" do
      delete :destroy, :id => @other_test_file.to_param, :format => 'js'
      response.should redirect_to(:controller => "test_files", :action => "index")
    end
  end
  
  
  describe "log_event" do
    before(:each) do
      session[:events] = nil
      controller.send(:log_event, "foo","bar","faz","baz")
    end
    it "should create session[:events] if it doesn't exist" do
      session[:events].should be_an(Array)
    end
    it "should add a category/action/label hash to the array" do 
      session[:events].should == [{category:"foo",action:"bar",label:"faz", value:"baz"}]
    end
  end

end
