module TestRunsHelper
  
  def test_class(test_result)
    "passed_#{test_result.result}"
  end
  
  def ran_tests(test_run)
    if !test_run.has_failures?
          "Ran #{pluralize(test_run.number_of_tests, 'test')} on #{pluralize(test_run.number_of_pages, 'page')} with no failures"
        else
          failure_message = "#{pluralize(test_run.number_of_tests, 'test')} on #{pluralize(test_run.number_of_pages, 'page')} resulted in #{pluralize(test_run.number_of_failing_groups, 'failing page')}"
          
          if test_run.number_of_failed_tests == 0
            return failure_message
          else
            return failure_message + " and #{pluralize(test_run.number_of_failed_tests, 'failing tests')}"
          end
        end
  end
  
  def test_run_path(test_run)
    "test_runs/#{test_run.id}"
  end
end
