class UserMailer < ActionMailer::Base
  default from: "Citrulu <contact@citrulu.com>"
  default "Message-ID"=>"#{Digest::SHA2.hexdigest(Time.now.to_s)}@citrulu.com"

  def test_notification(test_run)
    @test_run = test_run
    
    if @test_run.has_groups_with_failed_tests?
      @status = :fail
      @title = subject = "#{@test_run.number_of_failed_tests} of your tests just failed"
      # There may *also* be a number of pages which could not be retrieved, but we'll leave this out of the subject line.
    elsif @test_run.has_failed_groups?
      @status = :fail
      @title = subject = "#{@test_run.number_of_failed_groups} pages could not be retrieved"
    else
      @status = :pass
      @title = subject = 'All of your tests are passing'
    end

    to = test_run.test_file.user.email
    headers("Auto-Submitted" => "auto-generated", "List-Unsubscribe" => "<#{url_for(:controller => "registrations", :action => "edit", :only_path => false) }>")

    mail(to: to, subject: subject)
  end

  def welcome_email(user)
    @title = "Welcome to Citrulu"
    mail(to: user.email, subject: "Welcome to Citrulu")
  end
end
