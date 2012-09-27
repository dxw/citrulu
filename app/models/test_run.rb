class TestRun < ActiveRecord::Base
  require 'symbolizer' 
 
  belongs_to :test_file
  has_many :test_groups, :dependent => :destroy

  default_scope :order => 'time_run DESC'

  scope :past_week, lambda { where("time_run > ?", Time.now - 7.days) }    
    #http://guides.rubyonrails.org/active_record_querying.html#working-with-times
  scope :user_test_runs, lambda { |user| joins(:test_file => [:user]).where("user_id = ?", user.id) }

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
  
  

  def owner
    test_file.user
  end
  
  def previous_run
    # The ID comparison shouldn't be nescessary, but apparently Is
    test_file.test_runs.select{|run| (run.id != id) && (run.time_run < time_run) }.max{|a,b|a.time_run <=> b.time_run}
    
    # Definition by ID is cleaner but probably not what we should be doing...
    # test_file.test_runs.select{|run|run.id < id}.max{|a,b|a.id <=> b.id}
  end
  
  # Are there any other test_runs?
  def users_first_run?
    test_file.test_runs(true) # Cache-busting
    test_file.test_runs.length == 1 && test_file.user.test_files.select{|f| (f.id != test_file.id) && !f.test_runs.empty?}.blank? 
  end  


  def self.delete_all_older_than(limit_date)
    where( "time_run < ?", limit_date).destroy_all    
  end
  
  #########
  # Stats #
  #########
  
  def pages_average_times
    test_groups.inject({}) do |hash, group| 
      return hash unless group.response                # Ignore groups where the page couldn't be retrieved at all
      return hash unless group.response.code == "200"  # Only interested in tests where the pages were successful
      fail "Found a group (id##{group.id}) with a response but no response_time" if group.response.response_time.nil?
      
      hash.merge({ group.test_url => group.response.response_time }){ |url, oldval, newval| (newval+oldval)/2 }
    end
  end
end
