require 'grammar/grammar'
require 'grammar/symbolizer'

class TestFile < ActiveRecord::Base
  belongs_to :user 
  has_many :test_runs

  class TestCompileError < StandardError
  end

  def self.format_error(error)
    matches = error.to_s.match(/^Expected( one of)? ((([^,]+,)*[^,]+) at) line (\d+), column (\d+) \(byte (\d+)\) after(.*)$/m)

    throw ArgumentError.new("This error doesn't match any of the expected formats: #{error.to_s}") if !matches

    results = {
      :hash => Digest::SHA1.hexdigest(matches[3]),
      :expected => matches[3],
      :line => matches[5],
      :column => matches[6],
      :after => matches[8],
    }

    case results[:after] 
    when ' '
      results[:after] = "a space" 
    when "\n" 
      results[:after] = "a newline"
    else 
      results[:after] = "'" + results[:after] + "'"
    end

    results
  end

  def self.compile_tests(code)
    parser = TesterGrammarParser.new

    # Strip comments
    code.gsub!(/#[^\n]+\n/, '')

    # Ensure the file ends with a line return
    code = code + "\n"

    result = parser.parse(code)

    if result == nil
      if parser.failure_reason.nil?
        raise TestCompileError.new("An strange compiler error has occurred. Sorry! This is a bug. Please let us know")
      else
        raise TestCompileError.new(parser.failure_reason)
      end
    end

    result.process
  end

end
