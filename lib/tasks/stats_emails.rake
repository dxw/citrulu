desc "Enqueue all the stats emails"
task :enqueue_stats_emails => :environment do
  User.enqueue_all_stats_emails
end

desc "Send all the stats emails"
task :run_stats_emails => :environment do
  # User.send_all_stats_emails
  
  # Temporarily, instead: just send to Harry and Duncan so that we can check that it doesn't return nonsense
  harry = User.where(email:"harry@dxw.com").first
  duncan = User.where(email:"duncan@dxw.com").first
  
  harry.send_stats_email
  duncan.send_stats_email
end

desc "Send a status email to Harry and Duncan"
task :send_status_email => :environment do
  UserMailer.daily_status_email("harry@dxw.com").deliver
  UserMailer.daily_status_email("duncan@dxw.com").deliver
  
  if TestRun.past_days(1).count < 5
    UserMailer.daily_status_email("systems@dxw.com").deliver
  end
    
end