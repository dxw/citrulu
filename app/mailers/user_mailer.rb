class UserMailer < ActionMailer::Base
  default from: "Citrulu <contact@citrulu.com>"

  def test_notification(test_run)
    @test_run = test_run
    @failures = test_run.test_groups.sum{|x|x.test_results.select{|result| !result.result}.count}

    if @failures > 0
      @status = :fail
      @title = subject = "#{@failures} of your tests just failed"
    else
      @status = :pass
      @title = subject = 'All of your tests are passing'
    end

    to = test_run.test_file.user.email
    headers("Auto-Submitted" => "auto-generated", "List-Unsubscribe" => "<#{url_for(:controller => "registrations", :action => "edit", :only_path => false) }>")

    mail(to: to, subject: subject) do |format|
      format.html
    end
  end

  def welcome_email(user)
    @title = "Welcome to Citrulu"
    mail(to: user.email, subject: "Welcome to Citrulu")
  end
end
