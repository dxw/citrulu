class UserMailer < ActionMailer::Base
  default from: "Citrulu <contact@citrulu.com>"
  default "Message-ID"=>"#{Digest::SHA2.hexdigest(Time.now.to_s)}@citrulu.com"
  default "Auto-Submitted" => "auto-generated" 
  
  helper :application
  
  def welcome_email(user)
    @title = "Welcome to Citrulu"
    @first_tutorial_url = tutorial_url(user)
    
    mail(to: user.email, subject: @title)
  end
  
  def nudge(user)
    @title = "How are you getting on with Citrulu?"
    @first_tutorial_url = tutorial_url(user)
    # This will be required when we impose free trial limits:
    # @days_left_of_free_trial = user.days_left_of_free_trial
    
    mail(to: user.email, subject: @title)
  end
  
  def weekly_stats_email(user)
    @date = Date.today.to_s(:simple)
    @title = "Citrulu weekly test summary"
    subject = "Citrulu weekly test summary for #{ @date }"
    
    # Details of the current status:
    @number_of_running_test_files   = user.number_of_running_files
    @number_of_domains              = user.number_of_domains

    # Past week summary:
    @number_of_test_runs            = user.number_of_test_runs_in_past_week
    @number_of_failed_test_runs     = user.number_of_failed_test_runs_in_past_week
    @number_of_successful_test_runs = user.number_of_successful_test_runs_in_past_week
    @number_of_urls                 = user.number_of_urls_in_past_week

    # Past week lists:
    @broken_pages = user.broken_pages_list(user.urls_with_failures_in_past_week)
    @domains_list = user.domains_list

    @page_response_times = user.pages_average_times_in_past_week
    
    mail(to: user.email, subject: subject)
  end
  
  # For us to know if stuff is going wrong:
  def status_email(user)
    @date = Date.today.to_s(:simple)
    @title = "Citrulu daily status summary"
    subject = "Citrulu daily status summary for #{ @date }"
    
    # Details of the current status:
    @number_of_running_test_files   = user.number_of_running_files
    @number_of_domains              = user.number_of_domains

    # Past week summary:
    @number_of_test_runs            = user.number_of_test_runs_in_past_week
    @number_of_failed_test_runs     = user.number_of_failed_test_runs_in_past_week
    @number_of_successful_test_runs = user.number_of_successful_test_runs_in_past_week
    @number_of_urls                 = user.number_of_urls_in_past_week

    # Past week lists:
    @broken_pages = user.broken_pages_list(user.urls_with_failures_in_past_week)
    @domains_list = user.domains_list

    @page_response_times = user.pages_average_times_in_past_week
    
    mail(to: user.email, subject: subject, template_name: 'weekly_stats_email')
  end
  
  def first_test_notification_success(test_run)
    raise "Tried to create a test notification for a nil test run" if test_run.nil?
    @status = :pass
    @title = 'We ran your tests and they all pass!'
    subject = "#{@title} (#{test_run.test_file.name})"
    
    # TODO - DRY These up - couldn't work out how to do it!
    @test_run = test_run
    to = test_run.test_file.user.email
    headers( test_notification_headers )
    mail(to: to, subject: subject, template_name: 'first_test_notification')
  end

  def first_test_notification_failure(test_run)
    raise "Tried to create a test notification for a nil test run" if test_run.nil?
    raise "Tried to create a test notification for a test test_run with no groups: id#{test_run.id}" if test_run.test_groups.nil?
    
    @status = :fail
    @title = 'We ran your tests and some of them failed.'
    subject = "#{@title} (#{test_run.test_file.name})"
    
    # TODO - DRY These up - couldn't work out how to do it!
    @test_run = test_run
    to = test_run.test_file.user.email
    headers( test_notification_headers )
    mail(to: to, subject: subject, template_name: 'first_test_notification')
  end
  
  def test_notification_success(test_run)
    raise "Tried to create a test notification for a nil test run" if test_run.nil?
    @status = :pass
    @title = 'All of your tests are passing'
    subject = "#{@title} (#{test_run.test_file.name})"
    
    # TODO - DRY These up - couldn't work out how to do it!
    @test_run = test_run
    to = test_run.test_file.user.email
    headers( test_notification_headers )
    mail(to: to, subject: subject, template_name: 'test_notification')
  end
  
  def test_notification_failure(test_run)
    raise "Tried to create a test notification for a nil test run" if test_run.nil?
    raise "Tried to create a test notification for a test test_run with no groups: id#{test_run.id}" if test_run.test_groups.nil?
        
    @status = :fail
    if test_run.has_groups_with_failed_tests?
      @title = "#{test_run.number_of_failed_tests} of your tests just failed"
      # Some pages may have failed in this case as well, but we want to keep the title short
    else #test_run.has_failed_groups?
      @title = "#{test_run.number_of_failed_groups} pages could not be retrieved"
    end
    
    subject = "#{@title} (#{test_run.test_file.name})"
    
    # TODO - DRY These up - couldn't work out how to do it!
    @test_run = test_run
    to = test_run.test_file.user.email
    headers( test_notification_headers )
    mail(to: to, subject: subject, template_name: 'test_notification')
  end

  protected
  
  def test_notification_headers
    {"List-Unsubscribe" => "<#{url_for(:controller => "registrations", :action => "edit", :only_path => false) }>"}
  end 
  
  private 
  
  # Url which should point to the first tutorial
  def tutorial_url(user)
    if user.first_tutorial
      return edit_test_file_url(user.first_tutorial)
    else
      # They must have deleted the first tutorial file
      return test_files_url
    end
  end
end