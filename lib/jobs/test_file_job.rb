require 'testrunner'

class TestFileJob
  @queue = :test_file

  def self.perform(test_file_id)
    file = TestFile.find(test_file_id)
    TestRunner.run_test(file)
  end
end

class PriorityTestFileJob < TestFileJob
  @queue = :test_file_priority
end
