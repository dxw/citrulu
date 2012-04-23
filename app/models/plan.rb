class Plan < ActiveRecord::Base
  has_many :users
  
  # We should create the plan in Spreedly before adding it to this table
  validates_presence_of :spreedly_id 
  
  def self.default
    default_plan = where(:default => true).first
    if default_plan && default_plan.active?
      return default_plan
    else
      # Something's gone FOOBAR:
      cheapest_active_plan = Plan.where(:active => true).order('cost_usd asc').first
      if cheapest_active_plan.nil?
        raise "SOMETHING'S GONE FOOBAR! Couldn't find a default plan, or indeed any active plans at all!"
      else
        logger.error "SOMETHING'S GONE FOOBAR! Couldn't find a default plan, so returned the cheapest active plan (ID#{cheapest_active_plan.id}) instead. NOT IDEAL!"
      end
    end
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
  

  def self.cornichon
    self.where(:name => "Cornichon", :active => true)
  end
  
  def self.gherkin
    self.where(:name => "Gherkin", :active => true)
  end
  
  
  NAMES = {
    :silver => "Cornichon",
    :gold => "Gherkin",
  }
  
  def self.get_name_from_plan_level(plan_level)
    Plan::NAMES[plan_level.to_sym]
  end
  
  def self.get_spreedly_plan(plans, name)
    # There should only be one enabled plan per name...
    plans.select{|p| p.name == name && p.enabled = true }.first
  end

  def self.spreedly_plans
    RSpreedly::SubscriptionPlan.all
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