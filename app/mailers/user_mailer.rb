class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def _n(s1, s2, n)
    (n == 1) ? s1 : s2
  end

  def test_notification(test_group)
    @test_group = test_group
    @failures = test_group.test_results.select{|result| !result.result}.count

    if @failures > 0
      subject = _n('%d test just failed', '%d tests just failed', @failures) % @failures
    else
      subject = 'All tests passing'
    end
    to = test_group.test_run.test_file.user.email

    mail(to: to, subject: subject, template: 'test_notification')
  end
end
