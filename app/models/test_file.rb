require 'grammar/parser'
require 'grammar/symbolizer'

class TestFile < ActiveRecord::Base
  belongs_to :user 
  has_many :test_runs

  def self.format_error(error)
    @parser ||= CitruluParser.new

    @parser.format_error(error)
  end

  def self.compile_tests(code)
    @parser ||= CitruluParser.new
    
    if code.nil?
      raise @parser.no_code_exception
    else
      @parser.compile_tests(code)
    end
  end
  
  # All the files which have compiled successfully at some point
  def self.compiled_files
    all(:conditions => "compiled_test_file_text is not null")
  end
end
