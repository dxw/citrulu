class TestRun < ActiveRecord::Base

  
  belongs_to :test_file
  has_many :test_groups

# TEMPORARY CODE  
  require 'psych'
  DUMMY_RESULTS_YAML = %{---
- :test_url: http://harrymetcalfe.com
  :tests:
  - :assertion: :page_contain
    :value: Harry's Home on the Web
    :passed: true
  - :assertion: :page_not_contain
    :value: Harry's Home on the Web
    :passed: false
  - :assertion: :source_contain
    :value: This is an automatically generated list of things that might have something to do with me
    :passed: true
  - :assertion: :page_not_contain
    :value: PHP Error
    :passed: true
  - :assertion: :page_not_contain
    :value: PHP Warning
    :passed: true
  - :assertion: :headers_include
    :value: X-Varnish
    :passed: false
  - :assertion: :headers_not_include
    :value: X-Varnish
    :passed: true
  :test_date: 2012-02-29 15:55:03.709027957 +00:00}

  def test_run_object
    Psych.load(DUMMY_RESULTS_YAML)
  end
#END TEMPORARY CODE
  
  def number_of_pages
    test_groups.length
  end
  
  def number_of_checks
    count = 0
    test_groups.each do | test_group |
      count += tests.length
    end
    return count
  end
  
  def number_of_failures  
    # Simulate random successes and failures:
    
    unless time_run.to_i.modulo(5)==0
      0
    else
      rand(20) + 1
    end
  end
  
  
  #TODO should be in the helper? Didn't put it there initially on the assumption that this is useful in logic as well...
  def status
    if number_of_failures > 0
      "alert-error"
    else
      "alert-success"
    end
    # These are twitter bootstrap class names. I tried to define my own classes inheriting from these, but couldn't get it to work...
  end
end
