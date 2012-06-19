class Plan < ActiveRecord::Base
  has_many :users
  
  # We should create the plan in Spreedly before adding it to this table
  validates_presence_of :spreedly_id 
  
  alias_attribute :name, :name_en

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
        return cheapest_active_plan
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
    self.where(:name_en => "Cornichon", :active => true).first
  end
  
  def self.gherkin
    self.where(:name_en => "Gherkin", :active => true).first
  end
  
  def self.get_plan_name_from_plan_level(plan_level)
    LEVELS[plan_level.to_sym]
  end
  
  def self.get_plan_from_level(plan_level)
    Plan.where(:name_en => get_plan_name_from_plan_level(plan_level), :active => true).first
  end
  
  def self.get_spreedly_plan(plans, name)
    # There should only be one enabled plan per name...
    plans.select{|p| p.name == name && p.enabled = true }.first
  end

  def self.spreedly_plans
    RSpreedly::SubscriptionPlan.all
  end
    
  LEVELS = {
    :silver => "Cornichon",
    :gold => "Gherkin"
  }
  
  def self.limits
    [
      add(cornichon.number_of_sites, gherkin.number_of_sites, 'Number of sites', 'The maximum number of domains you can runs tests on'),
      add('Every Hour', 'Every Minute', 'Test Frequency', 'How often we\'ll run all your tests'),
      add("#{cornichon.mobile_alerts_allowance} per month", "#{gherkin.mobile_alerts_allowance} per month", 'Mobile alerts', 'Receive SMS messages when tests fail', true),
      add('Unlimited',  'Unlimited', 'Email alerts', 'Receive emails when tests fail'),
      add('Unlimited', 'Unlimited' , 'Test files', 'Structure your tests into several files. For example, you might want one per site.', true),
  #      add('?', '?', 'SLA', 'There should be different support SLAs?'),
    ]
  end

  def self.features 
    [
      add(true,  true, 'Human-friendly tests', 'Write tests in English'),
      add(true,  true, 'Browse test results', 'Look back over all your past test results'),
      add(true,  true, 'Use predefines', 'Write tests faster by searching for predefined lists of things to check for -- like PHP errors, warnings and notices'),
      add(cornichon.allows_custom_predefines, gherkin.allows_custom_predefines, 'Write custom Predefines', 'Write your own predefines, to make writing good tests for your apps quicker, tidier and easier to maintain', true),
      add(cornichon.allows_retrieved_pages, gherkin.allows_retrieved_pages, 'View retrieved pages', 'Look at the cached page we retrieved from your site to see exactly what was returned when we tested it', true),
      add(cornichon.allows_git_support, gherkin.allows_git_support, 'Git support', 'Edit your files locally, push them to Citrulu\'s git server, and we\'ll take them from there', true),
      add(cornichon.allows_tests_on_demand, gherkin.allows_tests_on_demand, 'Run tests on demand', 'Click on a button to schedule a test at any time, and get priority over other users\' runs', true),
    ]
  end
end