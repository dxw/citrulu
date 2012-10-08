desc "Enqueue all the stats emails"
task :enqueue_stats_emails => :environment do
  User.enqueue_all_stats_emails
end

desc "Send all the stats emails"
task :run_stats_emails => :environment do
  User.send_all_stats_emails
end

desc "Send a status email to Harry and Duncan"
task :send_status_email => :environment do
  UserMailer.daily_status_email("harry@dxw.com").deliver
  UserMailer.daily_status_email("duncan@dxw.com").deliver
  
  if TestRun.past_days(1).count < 5
    UserMailer.daily_status_email("systems@dxw.com").deliver
  end
    
end