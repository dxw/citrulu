require 'grammar/parser'
require 'grammar/predefs'
require 'mechanize'

class TestRunner

  def parser
    @parser ||= CitruluParser.new
    @parser
  end

  def run_all_tests
    return "Nothing to run" if TestFile.compiled_files.empty?
    
    TestFile.compiled_files.each do |file|
      test_run = TestRun.new
      test_run.time_run = Time.zone.now
      test_run.test_file_id = file.id
      test_run.save

      groups = execute_tests(parser.compile_tests(file.compiled_test_file_text))

      groups.each do |group|
        test_group = TestGroup.new
        test_group.test_run_id = test_run.id
        test_group.time_run = group[:test_date]
        test_group.response_time = group[:response_time]
        test_group.message = group[:message]
        test_group.test_url = group[:test_url]
        test_group.save

        group[:tests].each do |test|
          test_result = TestResult.new
          test_result.test_group_id = test_group.id
          test_result.assertion = test[:assertion]
          test_result.value = test[:value]
          test_result.name = test[:name]
          test_result.result = test[:passed]
          test_result.save
        end
      end
    end
  end

  def do_test(testvalues, &block)
    passed = false

    testvalues.each do |value|
      passed = yield(value)

      return passed if !passed
    end

    passed
  end

  def execute_tests(tests)
    tests.each do |group|
      agent = Mechanize.new

      if !group[:first].blank?
        agent.get(group[:first])
      end

      group[:test_date] = Time.now

      begin
        page = agent.get(group[:test_url])

        group[:response_time] = (Time.now - group[:test_date])*1000
        group[:response_code] = page.code
      rescue Exception => e

        group[:result] = :fail
        group[:message] = e.to_s

        next
      end
      
      if !group[:finally].blank?
        agent.get(group[:finally])
      end

      group[:tests].each do |test|
 
      testvalues = []

      if test[:value].blank? && !test[:name].blank?
        testvalues += Predefs.find(test[:name])
      else
        testvalues << test[:value]
      end

      case test[:assertion]
      when :i_see
        test[:passed] = do_test(testvalues) do |value|
          page.root.inner_text.match(value) != nil
        end

      when :i_not_see
        test[:passed] = do_test(testvalues) do |value|
          page.root.inner_text.match(value) == nil
        end

      when :source_contain
        test[:passed] = do_test(testvalues) do |value|
          page.content.match(value) != nil
        end

      when :source_not_contain
        test[:passed] = do_test(testvalues) do |value|
          page.content.match(value) == nil
        end

      when :headers_include
        test[:passed] = do_test(testvalues) do |value|
          page.header.include?(value)
        end

      when :headers_not_include
        test[:passed] = do_test(testvalues) do |value|
          !page.header.include?(value)
        end

      else
        test[:message] = "Internal error: no such test' #{test[:assertion]}"
      end
    end

    tests
  end

  end
end
