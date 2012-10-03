# encoding: utf-8
class WebsiteController < ApplicationController

  def features
    @names = Plan::LEVELS
    @limits = Plan.limits
    @features = Plan.features
    render :layout => "application"
  end
  
  def terms
    if current_user
      render :layout => "logged_in"
    else
      render :layout => "application"
    end
  end
end
