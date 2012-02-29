require 'treetop'
require_relative '../grammar.rb'


class Compiler
  
  class TestCompileError < StandardError
  end
  
  def compile_tests(code)
    parser = TesterGrammarParser.new

    result = parser.parse(code)

    if result == nil
      raise TestCompileError.new(parser.failure_reason.strip)
    end

    result.process
  end
end
