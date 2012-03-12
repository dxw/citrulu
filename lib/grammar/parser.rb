require 'treetop'
require 'grammar/grammar'

class CitruluParser < TesterGrammarParser
  class TestCompileError < StandardError
  end

  class TestPredefError < StandardError
  end

  class TestCompileUnknownError < StandardError
  end

  def self.format_error(error)
    matches = error.to_s.match(/^Expected( one of)? ((([^,]+,)*[^,]+) at) line (\d+), column (\d+) \(byte (\d+)\) after(.*)$/m)

    raise ArgumentError.new("This error doesn't match any of the expected formats: #{error.to_s}") if !matches

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
    if code.nil?
      raise ArgumentError.new("Something has gone wrong: we tried to compile a nonexistent Test File! Sorry! This is a bug. Please let us know")
    end
    
    # Strip comments & ensure the file ends with a line return
    result = parse(code + "\n")

    # Check for parser errors
    if result == nil
      if failure_reason.nil?
        raise TestCompileUnknownError.new("A strange compiler error has occurred. Sorry! This is a bug. Please let us know")
      else
        raise TestCompileError.new(failure_reason)
      end
    end
    
    parsed_object = result.process
    
    undefined_predefs = []
    parsed_object.each do |test_group|
      test_group[:tests].each do |test_result|
        unless test_result[:name].nil?
          begin 
            Predefs.find(test_result[:name])
          rescue Predefs::PredefNotFoundError
            undefined_predefs << test_result[:name]
          end
        end
      end
    end

    raise TestPredefError.new("The following predefines could not be found: #{undefined_predefs.join(", ")}") unless undefined_predefs.empty?


    parsed_object
  end
end
