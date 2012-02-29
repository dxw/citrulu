require 'spec_helper'

# def login
#   visit('/user/sign_in')
#   fill_in 'Email', :with => 'a@a.com'
#   fill_in 'Password', :with => 'password'
#   click_link 'Sign in'
# end
# 
# def logout
#   visit(destroy_user_session_path)
# end

# describe "TestFiles" do
#   describe "test file editor" do
#     
#     # before(:all) do
#     #       logout
#     #       login
#     #     end
#     it "updates the console when saving" do
#       logout
#       login unless user_signed_in?
#       @test_file = FactoryGirl.create(:test_file, :test_file_text => "Initial text")
#       visit(test_files_path)
#       #       find("#console pre").should have_content('foo')
#       #       put test_files_path, :test_file_text => "Some new text"
#       #       
#       #       within("#editor") do 
#       #         fill_in "editor_content", :with => "Some new text"
#       #       end
#       #       click_buton "Save"
# 
#       find("#console pre").should have_content('foo')
#     end
#   end
# end