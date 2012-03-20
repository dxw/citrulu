class TestRun < ActiveRecord::Base
  require 'symbolizer' 
  
  belongs_to :test_file
  has_many :test_groups

  default_scope :order => 'time_run DESC'
  
  def has_failures?
    number_of_failures != 0
  end
  
  def groups_with_failures
    # Speed things up if there haven't been any failures:
    return [] unless has_failures?
    
    test_groups.select{|g| g.has_failures? }
  end
  
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

  def owner
    test_file.user
  end
end
