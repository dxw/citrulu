require 'treetop'
require 'grammar/grammar'

require 'grammar/grammar_extensions.rb'

class CitruluParser < TesterGrammarParser

  class CitruluError < StandardError
  end

  class TestCompileError < CitruluError
  end

  class TestPredefError < CitruluError
  end

  class TestCompileUnknownError < CitruluError
  end

  def self.format_error(error)
    matches = parse_error(error)
    
    raise ArgumentError.new("This error doesn't match any of the expected formats: #{error.to_s}") if !matches

    results = {
      :hash => Digest::SHA1.hexdigest(matches[4]),
      :expected => matches[4],
      :expected_arr => matches[4].split(",").collect{|e| e.strip},
      :line => matches[6],
      :column => matches[7],
      :after => matches[9],
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
  
  def self.parse_error(error)
    error.to_s.match(/^(Line \d+: )?Expected( one of)? ((([^,]+,)*[^,]+) at) line (\d+), column (\d+) \(byte (\d+)\) after(.*)$/m)
  end

  def compile_tests(code)
    if code.blank?
      raise ArgumentError.new("Something has gone wrong: we tried to compile an empty or nonexistent Test File! Sorry! This is a bug. Please let us know")
    end
    
    # Ensure the file ends with a line return
    result = parse(code)

    # Check for parser errors
    if result.nil?
      if failure_reason.nil?
        raise TestCompileUnknownError.new("A strange compiler error has occurred. Sorry! This is a bug. Please let us know")
      else
        raise TestCompileError.new("Line #{failure_line}: #{failure_reason}")
      end
    end
    
    parsed_object = result.process
    
    check_predefines(parsed_object)

    parsed_object
  end
  
  def check_predefines(parsed_object)
    undefined_predefs = []
    parsed_object.each do |test_group|
      test_group[:tests].each do |test_result|
        undefined_predefs << test_result[:name] if test_result[:name] && !valid_predef?(test_result[:name])
      end
    end

    raise TestPredefError.new("The following predefines could not be found: #{undefined_predefs.join(", ")}") unless undefined_predefs.empty?
  end
  
  def valid_predef?(name)
    Predefs.find(name)
    true
  rescue Predefs::PredefNotFoundError
    false
  end
  
  def self.count_checks(parsed_object)
    raise ArgumentError, "Nil parsed object" if parsed_object.nil?
    # -1 to ignore the implicit response code checks
    parsed_object.sum{ |group| group[:tests].length - 1 }
  end
  
  # Get the number of unique domains in a parsed object
  def self.count_domains(parsed_object)
    self.domains(parsed_object).length
  end
  
  def self.domains(parsed_object)
    raise ArgumentError, "Nil parsed object" if parsed_object.nil?
    parsed_object.map{ |group| self.domain(group[:page][:url]) }.compact.uniq
  end
  
  def self.domain(url)
    PublicSuffix.parse(URI(url).host).domain
  rescue PublicSuffix::DomainInvalid
    # Do nothing - don't count this URL: return nil and compact the whole array to remove nils.
  end
end
