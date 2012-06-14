require 'testrunner'

desc "Enqueue all the tests"
task :enqueue_tests => :environment do
  TestRunner.enqueue_all_tests
end
