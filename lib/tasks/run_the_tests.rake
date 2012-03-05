require 'testrunner'

desc "Run all the tests"
task :run_tests => :environment do
  runner = TestRunner.new

  runner.run_all_tests
end
