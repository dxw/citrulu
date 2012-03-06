require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

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

  describe "GET index" do
    # Nothing yet: the index page is just static atm.
  end
  
  describe "GET show" do
    it "assigns the requested test_file as @test_file" do
      test_file = FactoryGirl.create(:test_file)
      get :show, {:id => test_file.to_param}
      assigns(:test_file).should eq(test_file)
    end
  end
  
  describe "GET new" do
    it "assigns a new test_file as @test_file" do
      get :new
      assigns(:test_file).should be_a_new(TestFile)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested test_file as @test_file" do
      test_file = FactoryGirl.create(:test_file)
      get :edit, {:id => test_file.to_param}
      assigns(:test_file).should eq(test_file)
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new TestFile" do
        expect {
          post :create, {:test_file => valid_create_attributes}
        }.to change(TestFile, :count).by(1)
      end
  
      it "assigns a newly created test_file as @test_file" do
        post :create, {:test_file => valid_create_attributes}
        assigns(:test_file).should be_a(TestFile)
        assigns(:test_file).should be_persisted
      end
  
      it "redirects to the created test_file" do
        post :create, {:test_file => valid_create_attributes}
        response.should redirect_to(TestFile.last)
      end
    end
  
    describe "with invalid params" do
      it "assigns a newly created but unsaved test_file as @test_file" do
        # Trigger the behavior that occurs when invalid params are submitted
        TestFile.any_instance.stub(:save).and_return(false)
        post :create, {:test_file => {}}
        assigns(:test_file).should be_a_new(TestFile)
      end
  
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TestFile.any_instance.stub(:save).and_return(false)
        post :create, {:test_file => {}}
        response.should render_template("new")
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
    
    describe "with valid params" do
      it "updates the requested test_file" do
        test_file = FactoryGirl.create(:test_file)
        # Assuming there are no other test_files in the database, this
        # specifies that the TestFile created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TestFile.any_instance.should_receive(:update_attributes).with(valid_update_attributes)
        put :update, {:id => test_file.to_param, :test_file => valid_update_attributes}
        # DGMS - Not sure if the above is correct... here's the scaffold:
        # TestFile.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        # put :update, {:id => test_file.to_param, :test_file => {'these' => 'params'}}
      end
  
      it "assigns the requested test_file as @test_file" do
        test_file = FactoryGirl.create(:test_file)
        put :update, {:id => test_file.to_param, :test_file => valid_update_attributes}
        assigns(:test_file).should eq(test_file)
      end
      
      it "handles a test file with nil text" do
        test_file = FactoryGirl.create(:test_file)
        TestFile.any_instance.should_receive(:update_attributes).with("test_file_text" => nil)
        put :update, {:id => test_file.to_param, :test_file => valid_update_attributes.merge({"test_file_text" => nil})}
        successful_update
      end
      
      it "handles a test file with empty text" do
        test_file = FactoryGirl.create(:test_file)
        TestFile.any_instance.should_receive(:update_attributes).with("test_file_text" => "")
        put :update, {:id => test_file.to_param, :test_file => valid_update_attributes.merge({"test_file_text" => ""})}
        successful_update
      end
    end
  
    describe "with invalid params" do
      it "assigns the test_file as @test_file" do
        test_file = FactoryGirl.create(:test_file)
        # Trigger the behavior that occurs when invalid params are submitted
        TestFile.any_instance.stub(:save).and_return(false)
        put :update, {:id => test_file.to_param, :test_file => {}}
        assigns(:test_file).should eq(test_file)
      end
  
      it "renders an error message"
    end
  end
  
  describe "DELETE destroy" do
    it "destroys the requested test_file" do
      test_file = FactoryGirl.create(:test_file)
      expect {
        delete :destroy, {:id => test_file.to_param}
      }.to change(TestFile, :count).by(-1)
    end
  
    it "redirects to the test_files list" do
      test_file = FactoryGirl.create(:test_file)
      delete :destroy, {:id => test_file.to_param}
      response.should redirect_to(test_files_url)
    end
  end

end
