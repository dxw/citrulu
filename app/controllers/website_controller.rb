class WebsiteController < ApplicationController
  
  # def after_sign_up_path_for(resource)
  #    "/test_file_editor"
  #  end

  def features
    def add(silver, gold, name, description, comingsoon = false) 
      {
        :name => name, 
        :description => description,
        :silver => silver,
        :gold => gold,
        :comingsoon => comingsoon
      }
    end

    @limits = [
      add('$14.95/month', '$49.95/month', 'Cost', 'Monthly cost'),
      add('3', '30', 'Number of sites', 'The maximum number of domains you can runs tests on'),
      add('Four times a day', 'Four times an hour', 'Test Frequency', 'How often we\'ll run all your tests'),
      add(3, 'Unlimited' , 'Test files', 'Structure your tests into several files. For example, you might want one per site.', true),
      add('12 per month', '120 per month', 'Mobile alerts', 'Receive SMS messages when tests fail', true),
      add('Unlimited',  'Unlimited', 'Email alerts', 'Receive emails when tests fail'),
#      add('?', '?', 'SLA', 'There should be different support SLAs?'),
    ]

    @features = [
      add(true,  true, 'Human-friendly tests', 'Write tests in English'),
      add(true,  true, 'Browse test results', 'Look back over all your past test results'),
      add(true,  true, 'Use predefines', 'Write tests faster by searching for predefined lists of things to check for -- like PHP errors, warnings and notices'),
      add(false, true, 'Write custom Predefines', 'Write your own predefines, to make writing good tests for your apps quicker, tidier and easier to maintain', true),
      add(false, true, 'View retrieved pages', 'Look at the cached page we retrieved from your site to see exactly what was returned when we tested it', true),
      add(false, true, 'Git support', 'Edit your files locally, push them to Citrulu\'s git server, and we\'ll take them from there', true),
      add(false, true, 'Run tests on demand', 'Click on a button to schedule a test at any time, and get priority over other users\' runs', true),
    ]

    render :layout => "logged_in"
  end
  
  def terms
    render :layout => "logged_in"
  end

  def email
    @title = "Citrulu summary 2012-04-05"

    @user = current_user

    test_runs = @user.one_week_of_test_runs

    @stats = {
      :week_total_test_runs => test_runs.size,
      :week_failed_test_runs => test_runs.select{|r| r.has_failures?}.size,
    }

    @broken_pages = []

    test_runs.collect{|r| r.groups_with_failed_tests.collect{|g| g if g.failed_tests}}.flatten.uniq{|a| a.test_url}.each do |group|
      @broken_pages << {
        :url => group.test_url,
        :badness => group.fail_frequency_string,
        :fails_this_week => test_runs.collect{|r| r.test_groups.find_all_by_test_url(group.test_url)}.flatten.select{|g| g.failed? || g.number_of_failed_tests > 0}.size
      }
    end
    
    @broken_pages.sort!{|a,b| b[:fails_this_week] <=> a[:fails_this_week]}



    render :layout => "user_mailer"
  end
end
