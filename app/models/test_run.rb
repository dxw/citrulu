class TestRun < ActiveRecord::Base
  require 'symbolizer' 
  
  belongs_to :test_file
  has_many :test_groups

  default_scope :order => 'time_run DESC'
  
  def number_of_pages
    test_groups.length
  end
  
  def number_of_checks
    count = 0
    test_groups.each do | test_group |
      count += test_group.test_results.length
    end
    return count
  end
  
  def number_of_failures  
    count = 0
    test_groups.each do | test_group |
      count += test_group.test_results.select{|result| result.failed?}.length
    end
    return count
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
