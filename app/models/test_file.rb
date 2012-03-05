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

    @parser.compile_tests(code)
  end

end
