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

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TestFilesController. Be sure to keep this updated too.
  def valid_session
    # this is a session when logged out:
    # {"session_id"=>"86d737213901dea6b46cfcd40433c102", "_csrf_token"=>"zaOa2EWRy6BFw+HTzNez35brgNogxNEius2bfx2rTqE=", "user_return_to"=>"/test_files"}
    
    # this is the full session when logged in:
    # {"session_id"=>"e4479e231f633785112df5146a7b7c30", "_csrf_token"=>"fzyINhfJqhgzzASApPor5Zzk912rjIkobtkE5XjAV3c=", "warden.user.user.key"=>["User", [1], "$2a$10$GnpUXtc.bTriO.VmULmXlu"], "flash"=>#<ActionDispatch::Flash::FlashHash:0x0000010239a2f8 @used=#<Set: {}>, @closed=false, @flashes={}, @now=nil>}
    
    # {
    #       "session_id"=>"e4479e231f633785112df5146a7b7c30", 
    #       "_csrf_token"=>"fzyINhfJqhgzzASApPor5Zzk912rjIkobtkE5XjAV3c=", 
    #       "warden.user.user.key"=>["User", [1], "$2a$10$GnpUXtc.bTriO.VmULmXlu"],   
    #     }
  end
  # 
  # describe "GET index" do
  #   it "assigns all test_files as @test_files" do
  #     test_file = FactoryGirl.create(:test_file)
  #     get :index, {}, valid_session
  #     assigns(:test_files).should eq([test_file])
  #   end
  # end
  # 
  # describe "GET show" do
  #   it "assigns the requested test_file as @test_file" do
  #     test_file = FactoryGirl.create(:test_file)
  #     get :show, {:id => test_file.to_param}, valid_session
  #     assigns(:test_file).should eq(test_file)
  #   end
  # end
  # 
  # describe "GET new" do
  #   it "assigns a new test_file as @test_file" do
  #     get :new, {}, valid_session
  #     assigns(:test_file).should be_a_new(TestFile)
  #   end
  # end
  # 
  # describe "GET edit" do
  #   it "assigns the requested test_file as @test_file" do
  #     test_file = FactoryGirl.create(:test_file)
  #     get :edit, {:id => test_file.to_param}, valid_session
  #     assigns(:test_file).should eq(test_file)
  #   end
  # end
  # 
  # describe "POST create" do
  #   describe "with valid params" do
  #     it "creates a new TestFile" do
  #       expect {
  #         post :create, {:test_file => valid_attributes}, valid_session
  #       }.to change(TestFile, :count).by(1)
  #     end
  # 
  #     it "assigns a newly created test_file as @test_file" do
  #       post :create, {:test_file => valid_attributes}, valid_session
  #       assigns(:test_file).should be_a(TestFile)
  #       assigns(:test_file).should be_persisted
  #     end
  # 
  #     it "redirects to the created test_file" do
  #       post :create, {:test_file => valid_attributes}, valid_session
  #       response.should redirect_to(TestFile.last)
  #     end
  #   end
  # 
  #   describe "with invalid params" do
  #     it "assigns a newly created but unsaved test_file as @test_file" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       TestFile.any_instance.stub(:save).and_return(false)
  #       post :create, {:test_file => {}}, valid_session
  #       assigns(:test_file).should be_a_new(TestFile)
  #     end
  # 
  #     it "re-renders the 'new' template" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       TestFile.any_instance.stub(:save).and_return(false)
  #       post :create, {:test_file => {}}, valid_session
  #       response.should render_template("new")
  #     end
  #   end
  # end
  # 
  # describe "PUT update" do
  #   describe "with valid params" do
  #     it "updates the requested test_file" do
  #       test_file = FactoryGirl.create(:test_file)
  #       # Assuming there are no other test_files in the database, this
  #       # specifies that the TestFile created on the previous line
  #       # receives the :update_attributes message with whatever params are
  #       # submitted in the request.
  #       TestFile.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, {:id => test_file.to_param, :test_file => {'these' => 'params'}}, valid_session
  #     end
  # 
  #     it "assigns the requested test_file as @test_file" do
  #       test_file = FactoryGirl.create(:test_file)
  #       put :update, {:id => test_file.to_param, :test_file => valid_attributes}, valid_session
  #       assigns(:test_file).should eq(test_file)
  #     end
  # 
  #     it "redirects to the test_file" do
  #       test_file = FactoryGirl.create(:test_file)
  #       put :update, {:id => test_file.to_param, :test_file => valid_attributes}, valid_session
  #       response.should redirect_to(test_file)
  #     end
  #   end
  # 
  #   describe "with invalid params" do
  #     it "assigns the test_file as @test_file" do
  #       test_file = FactoryGirl.create(:test_file)
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       TestFile.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => test_file.to_param, :test_file => {}}, valid_session
  #       assigns(:test_file).should eq(test_file)
  #     end
  # 
  #     it "re-renders the 'edit' template" do
  #       test_file = FactoryGirl.create(:test_file)
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       TestFile.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => test_file.to_param, :test_file => {}}, valid_session
  #       response.should render_template("edit")
  #     end
  #   end
  # end
  # 
  # describe "DELETE destroy" do
  #   it "destroys the requested test_file" do
  #     test_file = FactoryGirl.create(:test_file)
  #     expect {
  #       delete :destroy, {:id => test_file.to_param}, valid_session
  #     }.to change(TestFile, :count).by(-1)
  #   end
  # 
  #   it "redirects to the test_files list" do
  #     test_file = FactoryGirl.create(:test_file)
  #     delete :destroy, {:id => test_file.to_param}, valid_session
  #     response.should redirect_to(test_files_url)
  #   end
  # end

end
