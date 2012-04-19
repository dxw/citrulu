require 'grammar/parser'
require 'grammar/predefs'
require 'mechanize'

class TestRunner
  class TestCompileError < Exception
  end

  def self.run_all_tests
    return "Nothing to run" if TestFile.compiled_files.empty?
    
    TestFile.compiled_files.each do |file|
      if file.user.nil?
        raise "TestRunner tried to run tests on an orphaned test file (id: #{file.id}) - user was nil."
      end
      
      test_run = TestRun.create(
        :time_run => Time.zone.now,
        :test_file => file
      )
      
      execute_test_groups(file, test_run)
      
      if file.user.email_preference == 1
        # Send email if:
        # 1. It's not the first run
        # 2. The current run has failures OR the previous run had failures
        if test_run.has_failures? || (test_run.previous_run && test_run.previous_run.has_failures?)
          if test_run.has_failures?
            mail = UserMailer.test_notification_failure(test_run)
          else # no failures this run, but the previous run exists and had failures
            mail = UserMailer.test_notification_success(test_run)
          end
          mail.deliver
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
    def self.handle_retrieved_page(agent, page, group_params, group)
      group_params[:response_time] = agent.agent.http.last_response_time
      group_params[:response_code] = page.code
      
      begin
        agent.get(group[:finally]) unless group[:finally].blank?

        group_params[:test_results_attributes] = get_test_results(page, group[:tests])
        
      rescue Exception => e
        group_params[:message] = e.to_s
      end
        
      group_params
    end

    test_groups.collect do |group|
      group_params = {}

      begin
        group_params[:test_url] = group[:page][:url]
        group_params[:so] = group[:page][:so]
        group_params[:method] = group[:page][:method]
        group_params[:data] = group[:page][:data]
        
        agent = Mechanize.new
        agent.open_timeout = 5
        agent.read_timeout = 5
        agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        agent.user_agent = "CitruluBot/1.0"
        
        agent.get(group[:first]) unless group[:first].blank?
        
        group_params[:time_run] = Time.now

        url = URI.parse(group[:page][:url])

        agent.auth(url.user, url.password) if url.user

        page = agent.send(group[:page][:method], url.scheme + '://' + url.host + (url.port == 80 ? '' : ":#{url.port}") + url.path + (url.query.blank? ? '' : '?' + url.query), group[:page][:data])

      rescue Mechanize::ResponseCodeError => e
        handle_retrieved_page(agent, e.page, group_params, group)
      rescue Exception => e
        group_params[:message] = e.to_s
        # TODO Should be able to use "ensure" to make sure group_params is called, but that doesn't get called correctly for some reason -
        # ends up returning e.to_s instead...
        group_params
      else
        handle_retrieved_page(agent, page, group_params, group)
      end
    end
  end
  
  
  def self.get_test_results(page, tests)
    tests.collect do |test|
      test_result_params = { :original_line => test[:original_line] }

      testvalues = get_test_values(test)

      case test[:assertion]
      when :response_code_be
        test_result_params[:result] = do_test(testvalues) do |value|
          match_or_include(page.code.to_s, value)
        end

      when :response_code_not_be
        test_result_params[:result] = do_test(testvalues) do |value|
          !match_or_include(page.code.to_s, value)
        end

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
          header_exists?(page, value)
        end

      when :headers_not_include
        test_result_params[:result] = do_test(testvalues) do |value|
          !header_exists?(page, value)
        end

      when :contain
        test_result_params[:result] = do_test(testvalues) do |value|
          header_equals?(page, test[:header], value)
        end

      when :not_contain
        test_result_params[:result] = do_test(testvalues) do |value|
          !header_equals?(page, test[:header], value)
        end

      else
        raise ArgumentError.new "Internal error: no such test' #{test_result_params[:assertion]}"
      end
      
      test_result_params
    end
  end
  
  def self.match_or_include(string, value)
    if value.class == Regexp
      string.match(value)
    else
      string.downcase.include?(value.downcase)
    end
  end

  def self.text_is_in_page?(page, text)
    match_or_include(page.root.inner_text, text)
  end
  
  def self.source_is_in_page?(page, source_fragment)
    match_or_include(page.content, source_fragment)
  end
  
  def self.header_exists?(page, header)
    found = false

    page.header.keys.each do |key|
      if match_or_include(key, header)
        found = true
        break
      end
    end

    found
  end
  
  def self.header_equals?(page, header, value)
    header_exists?(page, header) && match_or_include(page.header[header.downcase], value)
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
      value.downcase! unless value.class == Regexp

      passed = yield(value)

      return passed if !passed
    end

    passed
  end
end
