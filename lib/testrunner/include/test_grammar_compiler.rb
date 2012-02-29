require 'treetop'
require_relative '../grammar.rb'
require_relative 'symbolizer.rb'


class Compiler
  
  class TestCompileError < StandardError
  end
  
  def compile_tests(code)
    parser = TesterGrammarParser.new

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
