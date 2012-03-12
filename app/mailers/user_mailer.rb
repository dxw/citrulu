class UserMailer < ActionMailer::Base
  default from: "from@example.com"

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

    mail(to: to, subject: subject, template: 'test_notification')
  end
end
