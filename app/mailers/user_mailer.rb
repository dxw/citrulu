class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def test_notification(test_group)
    failures = test_group.test_results.select{|result| !result.result}.count

    subject = '%d test just failed' % failures
    to = test_group.test_run.test_file.user.email

    mail(to: to, subject: subject)
  end
end
