class TestRun < ActiveRecord::Base
  require 'symbolizer' 
  
  belongs_to :test_file
  has_many :test_groups, :dependent => :destroy

  default_scope :order => 'time_run DESC'
  
  def groups_with_failures
    test_groups.select{|g| g.failed? || g.has_failed_tests?}
  end
  
  def has_failures?
    has_failed_groups? || has_groups_with_failed_tests?
  end
  
  def number_of_failing_groups
    groups_with_failures.count
  end
  
  
  def number_of_failed_groups
    test_groups.select{|g| g.failed? }.count
  end
  
  def has_failed_groups?
    number_of_failed_groups > 0
  end
  
  
  def number_of_failed_tests 
    # Not accounting for whole groups which failed.
    test_groups.collect{|g| g.number_of_failed_tests}.sum
  end

  def has_groups_with_failed_tests?
    number_of_failed_tests > 0
  end
  
  
  def number_of_pages
    test_groups.length
  end
  
  def number_of_tests
    test_groups.collect{|g| g.test_results.length }.sum
  end
  
  

  def owner
    test_file.user
  end
end
