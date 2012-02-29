require 'treetop'
require './grammar.rb'
require 'mechanize'
require 'yaml'

class TestCompileError < StandardError
end

class Tester

  def compile_tests(code)
    parser = TesterGrammarParser.new

    result = parser.parse(code)

    if result == nil
      raise TestCompileError.new(parser.failure_reason)
    end

    result.process
  end

  def run_tests(tests)
    agent = Mechanize.new

    tests.each do |group|
      puts "Running tests for #{group[:test_url]}..."

      group[:test_date] = Time.now

      begin
        page = agent.get(group[:test_url])
      rescue Mechanize::ResponseCodeError => e

        group[:result] = :fail
        group[:message] = e.to_s

        next
      end
      
      group[:tests].each do |test|
        case test[:assertion]
       when :page_contain 
         test[:passed] = page.root.inner_text.match(test[:value]) != nil
          
       when :page_not_contain
         test[:passed] = page.root.inner_text.match(test[:value]) == nil

        when :source_contain
          test[:passed] = page.content.match(test[:value]) != nil

        when :source_not_contain
          test[:passed] = page.content.match(test[:value]) == nil

        when :headers_include
          test[:passed] = page.header.include?(test[:value])

        when :headers_not_include
          test[:passed] = !page.header.include?(test[:value])

        else
          test[:message] = "Internal error: no such test' #{test[:assertion]}"
        end
      end
    end

    tests
  end
end

tg = Tester.new

code = File.read('bigger_example.test')

tests = tg.compile_tests(code)

puts tg.run_tests(tests).to_yaml
