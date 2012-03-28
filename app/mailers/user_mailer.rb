class UserMailer < ActionMailer::Base
  default from: "Citrulu <contact@citrulu.com>"
  default "Message-ID"=>"#{Digest::SHA2.hexdigest(Time.now.to_s)}@citrulu.com"


  def welcome_email(user)
    @title = "Welcome to Citrulu"
    mail(to: user.email, subject: "Welcome to Citrulu")
  end

  def test_notification_success(test_run)
    raise "Tried to create a test notification for a nil test run" if test_run.nil?
    @status = :pass
    @title = 'All of your tests are passing'
    
    # TODO - DRY These up - couldn't work out how to do it!
    @test_run = test_run
    to = test_run.test_file.user.email
    headers("Auto-Submitted" => "auto-generated", "List-Unsubscribe" => "<#{url_for(:controller => "registrations", :action => "edit", :only_path => false) }>")
    mail(to: to, subject: @title, template_name: 'test_notification')
  end
  
  def test_notification_failure(test_run)
    raise "Tried to create a test notification for a nil test run" if test_run.nil?
    raise "Tried to create a test notification for a test test_run with no groups: id#{test_run.id}" if test_run.test_groups.nil?
    
    @failures = test_run.test_groups.sum{|x|x.test_results.select{|result| !result.result}.count}
    
    @status = :fail
    @title = "#{@failures} of your tests just failed"
    
    # TODO - DRY These up - couldn't work out how to do it!
    @test_run = test_run
    to = test_run.test_file.user.email
    headers("Auto-Submitted" => "auto-generated", "List-Unsubscribe" => "<#{url_for(:controller => "registrations", :action => "edit", :only_path => false) }>")
    mail(to: to, subject: @title, template_name: 'test_notification')
  end
end
