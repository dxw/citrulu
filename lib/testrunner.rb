require 'grammar/parser'
require 'grammar/predefs'
require 'mechanize'

class TestRunner

  class TestCompileError < Exception
  end

  def self.run_all_tests
    return "Nothing to run" if TestFile.compiled_files.empty?
    
    TestFile.compiled_files.each do |file|
      test_run = TestRun.new
      test_run.time_run = Time.zone.now
      test_run.test_file_id = file.id
      test_run.save!
      
      execute_test_groups(file, test_run)
      
      if file.user.email_preference == 1
        #TODO: will this always work?
        previous_run = file.test_runs.select{|run|run.id < test_run.id}.first
        
        # Send email if:
        # 1. It's not the first run
        # 2. The current run has failures OR the previous run had failures
        if test_run.has_failures? || (previous_run && previous_run.has_failures?)
          mail = UserMailer.test_notification(test_run)
          mail.deliver
        else
        end
      end
    end
  end
  
  # Factored out to make testing possible
  def self.execute_test_groups(file, test_run)
    begin
      compiled_tests = CitruluParser.new.compile_tests(file.compiled_test_file_text)
    rescue CitruluParser::TestCompileError => e
      raise TestCompileError.new("Compile error on trying to execute test_groups in test file with id #{file.id}: #{e}")
    else
      # run the tests...
      test_run_params = execute_tests(compiled_tests)

      # create the objects in the database
      test_run_params.each do |test_group_params|
        test_group_params.merge! :test_run => test_run
        test_group = TestGroup.create(test_group_params)
      end
    end
  end  
  

  def self.execute_tests(test_groups)
    test_groups.collect do |group|
      group_params = {}
      group_params[:test_url] = group[:test_url]
      group_params[:original_line] = group[:original_line]
      
      agent = Mechanize.new

      agent.get(group[:first]) unless group[:first].blank?

      group_params[:time_run] = Time.now
      
      begin
        page = agent.get(group[:test_url])
      rescue Exception => e
        group_params[:message] = e.to_s
        # TODO Should be able to use "ensure" to make sure group_params is called, but that doesn't get called correctly for some reason -
        # ends up returning e.to_s instead...
        group_params
      else
        group_params[:response_time] = (Time.now - group_params[:time_run])*1000
        group_params[:response_code] = page.code
    
        agent.get(group[:finally]) unless group[:finally].blank?
    
        group_params[:test_results_attributes] = get_test_results(page, group[:tests])
        group_params
      end
    end
  end
  
  
  def self.get_test_results(page, tests)
    tests.collect do |test|
      test_result_params = {}
      test_result_params[:assertion] = test[:assertion]
      test_result_params[:value] = test[:value]
      test_result_params[:name] = test[:name]

      testvalues = get_test_values(test)

      case test[:assertion]
      when :i_see
        test_result_params[:result] = do_test(testvalues) do |value|
          text_is_in_page?(page, value)
        end

      when :i_not_see
        test_result_params[:result] = do_test(testvalues) do |value|
          !text_is_in_page?(page, value)
        end

      when :source_contain
        test_result_params[:result] = do_test(testvalues) do |value|
          source_is_in_page?(page, value)
        end

      when :source_not_contain
        test_result_params[:result] = do_test(testvalues) do |value|
          !source_is_in_page?(page, value)
        end

      when :headers_include
        test_result_params[:result] = do_test(testvalues) do |value|
          header_is_in_page?(page, value)
        end

      when :headers_not_include
        test_result_params[:result] = do_test(testvalues) do |value|
          !header_is_in_page?(page, value)
        end

      else
        raise ArgumentError.new "Internal error: no such test' #{test_result_params[:assertion]}"
      end
      
      test_result_params
    end
  end
  
  def self.text_is_in_page?(page, text)
    page.root.inner_text.match(text) != nil 
  end
  
  def self.source_is_in_page?(page, source_fragment)
    page.content.match(source_fragment) != nil
  end
  
  def self.header_is_in_page?(page, header)
    page.header.include?(value)
  end
  
  private 
  
  def self.get_test_values(test)
    if test[:value].blank?
      if test[:name].blank?
        raise ArgumentError.new "Internal error: test for '#{test[:assertion]}' with no name or value."
      else
        return Predefs.find(test[:name])
      end
    else
      return [test[:value]]
    end
  end
  
  def self.do_test(testvalues, &block)
    passed = false

    testvalues.each do |value|
      passed = yield(value)

      return passed if !passed
    end

    passed
  end
end
