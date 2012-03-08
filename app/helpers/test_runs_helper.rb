module TestRunsHelper
  
  def test_class(test_result)
    "passed_#{test_result.result}"
  end
  
  #return a test value or test name as appropriate
  def value_or_name(test_result)
    if !test_result.value.nil?
      # Value
      content = content_tag :span, test_result.value, :class => "test_value"
    elsif !test_result.name.nil?
      # Should have already ensured that the test_result name can be found before it was loaded into the db. 
      # In any case if .find Does raise an error, there's nothing we can do about it here.
      predefs = Predefs.find(test_result.name)
      content = content_tag :abbr, test_result.name, :title => predefs.join(", "), :rel => "tooltip",  :class => "predef_name" 
    else
      #raise?
    end
    
    content << content_tag(:strong, " (failed)")if test_result.failed?
    
    return content
  end
  
  
  def test_run_path(test_run)
    "test_runs/#{test_run.id}"
  end
end
