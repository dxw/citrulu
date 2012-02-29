require 'treetop'
require_relative '../grammar.rb'


class Compiler
  
  class TestCompileError < StandardError
  end

  def format_error(error)
    matches = error.to_s.match(/^Failed to compile: Expected one of ((([^,]+,)+[^,]+) at) line (\d+), column (\d+) \(byte (\d+)\) after(.*)$/)

    {
      :expected => matches[2].split(', '),
      :line => matches[4],
      :column => matches[5],
      :after => matches[7]
    }
  end
  
  def compile_tests(code)
    parser = TesterGrammarParser.new

    # Strip comments
    code.gsub!(/#[^\n]+\n/, '')

    # Ensure the file ends with a line return
    code = code + "\n"

    result = parser.parse(code)

    if result == nil
      
      if parser.failure_reason.nil?
        raise TestCompileError.new("Unknown error")
      else
        # For some unfathomable reason, the failure reason seems to include a newline at the end...
        raise TestCompileError.new(parser.failure_reason.strip!)
      end
    end

    result.process
  end
end
