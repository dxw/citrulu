require 'treetop'
require 'grammar/grammar'

class CitruluParser < TesterGrammarParser
  class TestCompileError < StandardError
  end

  class TestCompileUnknownError < StandardError
  end

  def format_error(error)
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

  def compile_tests(code)
    # Strip comments
    code.gsub!(/#[^\n]+\n/, '')

    # Ensure the file ends with a line return
    code = code + "\n"

    result = parse(code)

    if result == nil
      if failure_reason.nil?
        raise TestCompileUnknownError.new("An strange compiler error has occurred. Sorry! This is a bug. Please let us know")
      else
        raise TestCompileError.new(failure_reason)
      end
    end

    result.process
  end
end
