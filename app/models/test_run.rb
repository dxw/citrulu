class TestRun < ActiveRecord::Base
  require 'symbolizer' 
 
  belongs_to :test_file
  has_many :test_groups, :dependent => :destroy

  default_scope :order => 'time_run DESC'

  self.per_page = 50
  
  def groups_with_failures
    test_groups.select{|g| g.failed? || g.has_failed_tests?}
  end
    
  def number_of_failing_groups
    number_of_failed_groups + number_of_failed_tests
  end
  
  def has_failures?
    has_failed_groups? || has_groups_with_failed_tests?
  end
  
  
  def failed_groups 
    test_groups.select{|g| g.failed? }
  end
  
  def number_of_failed_groups
    failed_groups.count
  end
  
  def has_failed_groups?
    number_of_failed_groups > 0
  end
  
  
  def groups_with_failed_tests
    test_groups.select{|g| g.has_failed_tests?}
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
  
  def previous_run
    # The ID comparison shouldn't be nescessary, but apparently Is
    test_file.test_runs.select{|run| (run.id != id) && (run.time_run < time_run) }.max{|a,b|a.time_run <=> b.time_run}
    
    # Definition by ID is cleaner but probably not what we should be doing...
    # test_file.test_runs.select{|run|run.id < id}.max{|a,b|a.id <=> b.id}
  end
end
