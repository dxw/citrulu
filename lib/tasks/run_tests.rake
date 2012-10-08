require 'testrunner'

#This is just for manually running the tests - the Cron should be running enqueue_tests instead, after we fix it
desc "Run all the tests"
task :run_tests => :environment do
  TestRunner.run_all_tests
end
