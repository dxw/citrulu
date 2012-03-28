class TestRun < ActiveRecord::Base
  require 'symbolizer' 
  
  belongs_to :test_file
  has_many :test_groups, :dependent => :destroy

  default_scope :order => 'time_run DESC'
  
  def has_failures?
    test_groups.collect{|g| g.has_failures?}.uniq.include?(true) || number_of_failures != 0
  end
  
  def groups_with_failures
    # Speed things up if there haven't been any failures:
    return [] unless has_failures?
    
    test_groups.select{|g| g.has_failures? }
  end

  def number_of_failing_groups
    groups_with_failures.count
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
    test_groups.collect{|g| g.number_of_failures}.sum
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
