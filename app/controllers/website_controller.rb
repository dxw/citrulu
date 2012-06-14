class WebsiteController < ApplicationController

  def features
    @names = Plan::LEVELS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES

    render :layout => "logged_in"
  end
  
  def terms
    render :layout => "logged_in"
  end

  def email
    @title = "Citrulu summary 2012-04-05"

    @user = current_user

    test_runs = @user.one_week_of_test_runs

    @stats = {
      :week_total_test_runs => test_runs.size,
      :week_failed_test_runs => test_runs.select{|r| r.has_failures?}.size,
    }

    @broken_pages = []

    test_runs.collect{|r| r.groups_with_failed_tests.collect{|g| g if g.failed_tests}}.flatten.uniq{|a| a.test_url}.each do |group|
      @broken_pages << {
        :url => group.test_url,
        :badness => group.fail_frequency_string,
        :fails_this_week => test_runs.collect{|r| r.test_groups.find_all_by_test_url(group.test_url)}.flatten.select{|g| g.failed? || g.number_of_failed_tests > 0}.size
      }
    end
    
    @broken_pages.sort!{|a,b| b[:fails_this_week] <=> a[:fails_this_week]}

    render :layout => "user_mailer"
  end
end
