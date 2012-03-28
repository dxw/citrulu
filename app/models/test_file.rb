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
    
end
