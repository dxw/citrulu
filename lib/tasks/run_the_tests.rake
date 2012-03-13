require 'testrunner'

desc "Run all the tests"
task :run_tests => :environment do
  TestRunner.run_all_tests
end
