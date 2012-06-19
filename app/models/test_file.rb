require 'parser'
require 'symbolizer'

class TestFile < ActiveRecord::Base
  belongs_to :user 
  has_many :test_runs, :dependent => :destroy

  # By default we only deal with test files where 'deleted' is Not true
  scope :not_deleted, where("deleted IS NULL OR deleted = ?", false)
  scope :compiled, where("compiled_test_file_text IS NOT NULL")
  scope :tutorials, where("tutorial_id IS NOT NULL")
  scope :not_tutorial, where("tutorial_id IS NULL")
  scope :running, where(run_tests: true)
  scope :not_running, where("run_tests IS NULL OR run_tests = ?", false)
  
  validates_presence_of :name
  validates :name, uniqueness: {scope: :user_id}

  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end
  
  def last_run
    test_runs.order("time_run DESC").first
  end
  
  def due
    return false if !run_tests
    return false if deleted
    last_run.time_run + frequency < Time.now
  end

  def owner
    user
  end

  def number_of_pages
    unless compiled?
      raise ArgumentError.new("Tried to get 'number of pages' on a test file which has never compiled.")
    end
    
    @compiled_tests ||= CitruluParser.new.compile_tests(compiled_test_file_text)
    
    @compiled_tests.length 
  end
  
  def number_of_tests
    unless compiled?
      raise ArgumentError.new("Tried to get 'number of tests' on a test file which has never compiled.")
    end
    
    @compiled_tests ||= CitruluParser.new.compile_tests(compiled_test_file_text)
    
    count = 0
    @compiled_tests.each do |test_group|
      count += test_group[:tests].length
    end
    count
  end
  
  def compiled?
    !compiled_test_file_text.blank?
  end

   
  def average_failures_per_run
    return 0 if test_runs.size == 0

    fails = test_runs.collect{|r| r.number_of_failing_groups}
    (fails.inject(0.0) {|sum, n| sum + n} / fails.size).to_i
  end

  def average_fix_speed
    return 0 if test_runs.size == 0

    in_fail_spree = false
    fail_sprees = []
    start_fail = nil

    test_runs.sort{|a,b| a <=> b}.each do |run|
      if !in_fail_spree && run.has_failures?
        in_fail_spree = true
        start_fail = run
      elsif in_fail_spree && !run.has_failures?
        in_fail_spree = false

        fail_sprees << run.time_run - start_fail.time_run
      end
    end

    fail_sprees.inject(0.0){|sum,n| sum+n} / fail_sprees.size
  end
  
  def delete!
    update_attributes(deleted: true)
  end
  
  # For tutorial files - get the next tutorial file.
  def next_tutorial
    user.test_files.tutorials.where("tutorial_id > ?", tutorial_id).order("tutorial_id ASC").first
  end
  
  def is_a_tutorial
    !tutorial_id.nil?
  end

  def enqueue
    Resque.enqueue(TestFileJob, self.id)
  end

  def priority_enqueue
    Resque.enqueue(PriorityTestFileJob, self.id)
  end

  def prioritise
    Resque.dequeue(TestFileJob, self.id)
    Resque.enqueue(PriorityTestFileJob, self.id)
  end
end
