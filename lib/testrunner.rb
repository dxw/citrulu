require 'grammar/parser'
require 'grammar/predefs'
require 'digest/md5'

class TestRunner
  class TestCompileError < Exception
  end
  
  FAILURE_EMAIL_FREQUENCY = 1.hour
  MAX_CONTENT_BYTESIZE = 300*1024

  def self.enqueue_all_tests
    TestFile.not_deleted.running.compiled.each do |file|
      if file.user.nil?
        raise "TestRunner tried to run tests on an orphaned test file (id: #{file.id}) - user was nil."
      end
      
      # Only run tests for users who are paid up (or on the free trial)
      next if !file.user.active?

      file.enqueue if file.due
    end
  end
  
  def self.run_all_tests(force=false)
    TestFile.not_deleted.running.compiled.each do |file|
      if file.user.nil?
        raise "TestRunner tried to run tests on an orphaned test file (id: #{file.id}) - user was nil."
      end
      
      # Only run tests for users who are paid up (or on the free trial)
      next if !file.user.active?

      run_test(file) if file.due || force
    end
  end

  def self.run_test(file)
    if !file.run_tests?
      raise ArgumentError, "Tried to call TestRunner.run_test with a file that is set to not run"
    elsif file.deleted
      raise ArgumentError, "Tried to call TestRunner.run_test on a deleted test file"
    elsif !file.compiled?
      raise ArgumentError, "Tried to call TestRunner.run_test on a test file which hasn't compiled"
    end
    
    test_run = TestRun.create(
      :time_run => Time.zone.now,
      :test_file => file
    )
    
    execute_test_groups(file, test_run)
    
    if file.user.email_preference == 1
      # 1. If it's the first test run send a special email
      # 2. If tests failed, send a failure email
      # 3. If no tests failed, but the previous run had failing tests, send a success email
      if test_run.users_first_run?
        # This was the first test run:
        if test_run.has_failures?
          UserMailer.first_test_notification_failure(test_run).deliver
        else
          UserMailer.first_test_notification_success(test_run).deliver
        end
      elsif test_run.has_failures?
        email = UserMailer.test_notification_failure(test_run)
        
        # If it's exactly the same as the last failure email, don't send it unless some time has passed:
        #   First strip out the unique parts (at the moment only the link to the specific test run)
        email_hash = get_email_hash(email)

        if (email_hash != file.user.last_failure_email_hash) ||
          (file.user.last_failure_email_time.nil? ||
            (file.user.last_failure_email_time + FAILURE_EMAIL_FREQUENCY < Time.now))
          
          file.user.last_failure_email_hash = email_hash
          file.user.last_failure_email_time =  Time.now
          file.user.save!
          
          email.deliver
        end
      elsif test_run.previous_run && test_run.previous_run.has_failures?
        # previous had failures, but now everything is passing:
        UserMailer.test_notification_success(test_run).deliver
        
        file.user.last_failure_email_hash = nil
        file.user.last_failure_email_time = nil
        file.user.save!
      end
    end
  end  
  
  def self.get_email_hash(email)
    Digest::MD5.hexdigest(email.text_part.body.raw_source.gsub(/http\:\/\/.*\/test_runs\/[^\n]*/,""))
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
      group_params[:response_attributes] = {}
      group_params[:response_attributes][:response_time] = (agent.agent.http.last_response_time*1000).to_i
      group_params[:response_attributes][:headers] = page.header.collect{|header| "#{header[0]}: #{header[1]}"}.join("\n")
      group_params[:response_attributes][:code] = page.code

      begin
        agent.get(group[:finally]) unless group[:finally].blank?

        group_params[:test_results_attributes] = get_test_results(page, group[:tests])

        # Only save the page content if one of the tests has failed:
        if page.content && page.content.class == String && group_params[:test_results_attributes].any?{|x| !x[:result]}
          page_content = page.content.encode # Encode is maybe needed to force it into UTF-8?     
          if page_content.bytesize > MAX_CONTENT_BYTESIZE
            group_params[:response_attributes][:truncated] = true
            io = StringIO.new(page_content)
            io.truncate(MAX_CONTENT_BYTESIZE)
            page_content = io.read
          end
          
          group_params[:response_attributes][:content] = page_content
          group_params[:response_attributes][:content_hash] = Digest.hexencode(Digest::SHA256.new.digest(page_content))
        end
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
        agent.read_timeout = 15
        agent.redirect_ok = group[:page][:redirect]
        agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        agent.user_agent = "CitruluBot/1.0 (https://www.citrulu.com/bot)"
        
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
      !string.match(value).nil?
    else
      string.downcase.include?(value.downcase)
    end
  end


  def self.text_is_in_page?(page, text)
    page.respond_to?(:root) && match_or_include(page.root.inner_text.gsub(/[\s\n]+/, ' '), text)
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
