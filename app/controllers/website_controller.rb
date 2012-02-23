class WebsiteController < ApplicationController
  
  # def after_sign_up_path_for(resource)
  #    "/test_file_editor"
  #  end
    
  def index
  
  end
  
  def test_file_editor
    @test_file = current_user.test_file
  end
  
end
