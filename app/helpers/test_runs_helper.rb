module TestRunsHelper
  
  def test_class(test_result)
    "passed_#{test_result.result}"
  end
  
  #return a test value or test name as appropriate
  def value_or_name(test_result, plain_text=false)
    if !test_result.value.nil?
      # Value
      if plain_text
        content = '"' + test_result.value + '"'
      else
        content = content_tag :span, test_result.value, :class => "test_value"
      end
    elsif !test_result.name.nil?
      # Should have already ensured that the test_result name can be found before it was loaded into the db. 
      # In any case if .find Does raise an error, there's nothing we can do about it here.
      predefs = Predefs.find(test_result.name)
      if plain_text
        content = test_result.name
      else
        content = content_tag :abbr, test_result.name, :title => predefs.join(", "), :rel => "tooltip",  :class => "predef_name" 
      end
    else
      #raise?
    end
    
    if plain_text
      content = content + " (failed)" if test_result.failed?
    else
      content = content + content_tag(:strong, " (failed)") if test_result.failed?
    end
    
    return content
  end

  def ran_checks(test_run)
    if test_run.number_of_failures == 0 && test_run.number_of_failing_groups == 0
      "Ran #{pluralize(test_run.number_of_checks, 'check')} on #{pluralize(test_run.number_of_pages, 'page')} with no failures"
    else
      if test_run.number_of_failures == 0
        "#{pluralize(test_run.number_of_checks, 'test')} on #{pluralize(test_run.number_of_pages, 'page')} resulted in #{pluralize(test_run.number_of_failing_groups, 'failing page')}"
      else
        "#{pluralize(test_run.number_of_checks, 'test')} on #{pluralize(test_run.number_of_pages, 'page')} resulted in #{pluralize(test_run.number_of_failing_groups, 'failing page')} and #{pluralize(test_run.number_of_failures, 'failing tests')}"
      end
    end
  end
  
  def test_run_path(test_run)
    "test_runs/#{test_run.id}"
  end
end
