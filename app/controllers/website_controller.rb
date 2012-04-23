class WebsiteController < ApplicationController
  
  def features
    @names = Plan::LEVELS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES

    render :layout => "logged_in"
  end
  
end
