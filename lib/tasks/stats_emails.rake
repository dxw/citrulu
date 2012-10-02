desc "Enqueue all the stats emails"
task :enqueue_stats_emails => :environment do
  User.enqueue_all_stats_emails
end

desc "Send all the stats emails"
task :run_stats_emails => :environment do
  User.send_all_stats_emails
end