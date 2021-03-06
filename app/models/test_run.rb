class TestRun < ActiveRecord::Base
  require 'symbolizer' 
 
  belongs_to :test_file
  has_one :owner, :through => :test_file
  has_many :test_groups, :dependent => :destroy

  scope :past_days, lambda { |days| where("time_run > ?", Time.now - days.days) }    
  scope :has_failures, where(:id => TestGroup.has_failures.select(:test_run_id))
  
  def name
    "#{test_file.name}::#{time_run}"
  end

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
  
  
  def previous_run
    # Using "first" means that this will return either nil or the single object returned:
    previous_run_array = test_file.test_runs.where("(time_run < ?)", time_run).order("time_run DESC").limit(1).first
  end
  
  # Are there any other test_runs?
  def users_first_run?
    test_file.test_runs(true) # Cache-busting
    test_file.test_runs.length == 1 && owner.test_files.select{|f| (f.id != test_file.id) && !f.test_runs.empty?}.blank? 
  end  


  def self.delete_all_older_than(limit_date)
    where( "time_run < ?", limit_date).destroy_all    
  end

end
