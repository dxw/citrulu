require 'testrunner'

# IMPORTANT! These are just for manually running the tests - the Cron should be running enqueue_tests instead, after we fix it

desc "Run all the tests which are due"
task :run_tests => :environment do
  TestRunner.run_all_tests
end

desc "Run all the tests (even if they're not due)"
task :run_tests_force => :environment do
  TestRunner.run_all_tests(true)
end
