require 'parser'
require 'symbolizer'

class TestFile < ActiveRecord::Base
  belongs_to :user 
  has_many :test_runs, :dependent => :destroy
  
  validates_presence_of :name
  
  def last_run
    test_runs.max{|r,u| r.time_run <=> u.time_run }
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
  
  # All the files which have compiled successfully at some point
  def self.compiled_files
    #todo - put this select into sql
    all(:conditions => "compiled_test_file_text is not null").select{|f| f.compiled? }
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
      puts run.time_run
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
end
