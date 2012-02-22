class WebsiteController < ApplicationController
  
  def after_sign_up_path_for(resource)
    test_files_path
  end
    
  def index
  
  end
  
end
