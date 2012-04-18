class Plan < ActiveRecord::Base
  has_many :users
  
  validates_uniqueness_of :spreedly_id
  validates_presence_of :spreedly_id
  
  def self.default
    Plan.all.select{|p|p.default}.first
  end
  
  
  private
  
  def self.add(silver, gold, name, description, comingsoon = false) 
    {
      :name => name, 
      :description => description,
      :silver => silver,
      :gold => gold,
      :comingsoon => comingsoon
    }
  end

  public

  #TODO: should these be in a seperate file in config/initializers
  NAMES = {
    :silver => "Cornichon",
    :gold => "Gherkin",
  }
  
  def self.get_name_from_plan_level(plan_level)
    Plan::NAMES[plan_level.to_sym]
  end
  
  COSTS = 
    add('$14.95/month', '$49.95/month', 'Cost', 'Monthly cost')
  
  LIMITS = [
    add('3', '30', 'Number of sites', 'The maximum number of domains you can runs tests on'),
    add('Four times a day', 'Four times an hour', 'Test Frequency', 'How often we\'ll run all your tests'),
    add(3, 'Unlimited' , 'Test files', 'Structure your tests into several files. For example, you might want one per site.', true),
    add('12 per month', '120 per month', 'Mobile alerts', 'Receive SMS messages when tests fail', true),
    add('Unlimited',  'Unlimited', 'Email alerts', 'Receive emails when tests fail'),
#      add('?', '?', 'SLA', 'There should be different support SLAs?'),
  ]

  FEATURES = [
    add(true,  true, 'Human-friendly tests', 'Write tests in English'),
    add(true,  true, 'Browse test results', 'Look back over all your past test results'),
    add(true,  true, 'Use predefines', 'Write tests faster by searching for predefined lists of things to check for -- like PHP errors, warnings and notices'),
    add(false, true, 'Write custom Predefines', 'Write your own predefines, to make writing good tests for your apps quicker, tidier and easier to maintain', true),
    add(false, true, 'View retrieved pages', 'Look at the cached page we retrieved from your site to see exactly what was returned when we tested it', true),
    add(false, true, 'Git support', 'Edit your files locally, push them to Citrulu\'s git server, and we\'ll take them from there', true),
    add(false, true, 'Run tests on demand', 'Click on a button to schedule a test at any time, and get priority over other users\' runs', true),
  ]
end