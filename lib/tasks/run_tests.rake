require 'testrunner'

#This is just for manually running the tests - the Cron should be running enqueue_tests instead
desc "Run all the tests"
task :run_tests => :environment do
  puts "#{TestFile.count} Test files in total"
  puts "#{TestFile.compiled.count} Compiled Test files"
  # The outer loop duplicates the logic in TestRunner.enqueue_tests
  TestFile.not_deleted.running.compiled.each do |file|
    if file.user.nil?
      raise "TestRunner tried to run tests on an orphaned test file (id: #{file.id}) - user was nil."
    end
    
    puts "Test File ##{file.id} is set to not run" if !file.user.active?
    
    # Only run tests for users who are paid up (or on the free trial)
    next if !file.user.active?

    if file.due
      puts "About to run tests on Test File ##{file.id}"
      TestRunner.run_test(file)
    else
      puts "Test File ##{file.id} is not due - last run was at #{file.last_run.time_run}"
    end
  end
end