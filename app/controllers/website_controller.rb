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

  def email
    @title = "Citrulu summary 2012-04-05"

    @user = current_user
    
    @number_of_test_runs            = @user.number_of_test_runs_in_past_week
    @number_of_failed_test_runs     = @user.number_of_failed_test_runs_in_past_week
    @number_of_successful_test_runs = @user.number_of_successful_test_runs_in_past_week
    
    @number_of_running_test_files   = @user.number_of_running_files
    @number_of_domains              = @user.number_of_domains
    
    @broken_pages = @user.broken_pages_list(@user.urls_with_failures_in_past_week)
    
    @page_response_times = @user.pages_average_times
    
    # TODO:
    # Number of Groups 
    # Number of Urls
    # Total checks on each domain
    # Average Failures per Run
    # -- current_user.test_files.first.average_failures_per_run
    # Average Fix time 
    # -- distance_of_time_in_words(Time.now, Time.now + current_user.test_files.first.average_fix_speed.seconds)
    
    render :layout => "user_mailer"
  end
end
