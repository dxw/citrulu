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
  harry = User.where(email: "harry@dxw.com").first
  duncan = User.where(email: "duncan@dxw.com").first
  
  # Happy to let it fail noisily if either of these doesn't exist:
  harry.send_daily_status_email
  duncan.send_daily_status_email
end