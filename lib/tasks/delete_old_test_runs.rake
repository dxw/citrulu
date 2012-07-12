desc "Delete test runs older than 6 weeks"
task :delete_old_test_runs => :environment do
  TestRun.delete_all_older_than(Time.now - 6.weeks)
end