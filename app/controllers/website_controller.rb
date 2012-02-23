class WebsiteController < ApplicationController
  
  # def after_sign_up_path_for(resource)
  #    "/test_file_editor"
  #  end
    
  def index
    if user_signed_in?
      redirect_to test_files_path
    end
  end
  
end
