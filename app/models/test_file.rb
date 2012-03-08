require 'parser'
require 'symbolizer'

class TestFile < ActiveRecord::Base
  belongs_to :user 
  has_many :test_runs
  
  validates_presence_of :name
  
  def last_run
    TestRun.where(:test_file_id => id).first
  end

  # All the files which have compiled successfully at some point
  def self.compiled_files
    all(:conditions => "compiled_test_file_text is not null")
  end
  
  def create_default_test_file(user_id)
    self.create(
        :user => user_id,
        :name => "My first test file",
        :test_file_text => DEFAULT_TEST_FILE
      )
  end
    
end
