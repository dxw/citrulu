class WebsiteController < ApplicationController
  
  # def after_sign_up_path_for(resource)
  #    "/test_file_editor"
  #  end

  def features
    def add(bronze, silver, gold, name, description, comingsoon = false) 
      {
        :name => name, 
        :description => description,
        :bronze => bronze,
        :silver => silver,
        :gold => gold,
        :comingsoon => comingsoon
      }
    end

    @limits = [
      add('Free!', '10', '50', 'Cost', 'Monthly cost'),
      add('10', '500', 'Unlimited', 'URLs', 'The maximum number of individual URLs you can runs tests for'),
      add('Once a day', 'Twice a day', 'Once an hour', 'Test Frequency', 'How often we\'ll run all your tests'),
    ]

    @features = [
      add(true,  true,  true, 'Human-friendly tests', 'Write tests in English'),
      add(true,  true,  true, 'Predefines', 'Write tests faster by searching for predefined lists of things to check for -- like PHP errors, warnings and notices'),
      add(true,  true,  true, 'Browse test results', 'Look back over all your past test results'),
      add(true,  true,  true, 'Email alerts', 'Receive emails when tests fail'),
      add(false,  true,  true, 'Custom Predefines', 'Write your own predefines, to make writing good tests for your apps quicker', true),
      add(false, true,  true, 'Multiple test files', 'Structure your tests into several files. For example, you might want one per site.', true),
      add(false, true,  true, 'View retrieved pages', 'Look at the page we retrieved from your site to see exactly what was returned when we tested it', true),
      add(false, false, true, 'Mobile alerts', 'Receive SMS messages when tests fail', true),
      add(false, false, true, 'Run tests on demand', 'Click on a button to schedule a test at any time, and get priority over other users\' runs', true),
    ]

  end
  
end
