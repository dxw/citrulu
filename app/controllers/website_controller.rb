class WebsiteController < ApplicationController
  
  def features
    @names = Plan::NAMES
    @costs = Plan::COSTS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES

    render :layout => "logged_in"
  end
  
end
