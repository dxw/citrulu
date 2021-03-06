# encoding: utf-8
class Plan < ActiveRecord::Base
  has_many :users
  
  alias_attribute :name, :name_en
  
  scope :active, where(:active => true)

  def print_cost
    # Stored as a decimal, but round to the nearest pound for display:
    "£#{cost_gbp.to_i}"
  end
  
  def cost
    cost_gbp
  end

  
  def self.default
    default_plan = where(:default => true).first
    if default_plan && default_plan.active?
      return default_plan
    else
      # Something's gone FOOBAR:
      if cheapest_active_plan.blank?
        raise "SOMETHING'S GONE FOOBAR! Couldn't find a default plan, or indeed any active plans at all!"
      else
        logger.error "SOMETHING'S GONE FOOBAR! Couldn't find a default plan, so returned the cheapest active plan (ID#{cheapest_active_plan.id}) instead. NOT IDEAL!"
        return cheapest_active_plan
      end
    end
  end
  
  def self.cheapest_active_plan
    self.active.order('cost_gbp asc').first
  end

  def self.cornichon
    self.where(:name_en => "Super Tests", :active => true).first
  end
  def self.gherkin
    self.where(:name_en => "Mega Tests", :active => true).first
  end
  def self.cucumber
    self.where(:name_en => "Ultra Tests", :active => true).first
  end
  
  def self.get_plan_name_from_plan_level(plan_level)
    LEVELS[plan_level.to_sym]
  end
  
  def self.get_plan_from_level(plan_level)
    Plan.where(:name_en => get_plan_name_from_plan_level(plan_level), :active => true).first
  end
  
  def self.get_spreedly_plan(plans, name)
    # There should only be one enabled plan per name...
    plans.select{|p| p.name == name && p.enabled }.first
  end

  def self.spreedly_plans
    RSpreedly::SubscriptionPlan.all
  end
    
  LEVELS = {
    :bronze => "Super Tests",
    :silver => "Mega Tests",
    :gold => "Ultra Tests",
    :bespoke => "Super Turbo Tests",
  }
  
  def self.limits
    [
      add_limit(cornichon.number_of_sites, gherkin.number_of_sites, cucumber.number_of_sites, 'Loads!', 'Number of sites', 'The maximum number of domains you can runs tests on'),
      add_limit('Every Hour', 'Every 15 Minutes', 'Every 5 Minutes', 'Often as you like', 'Test Frequency', 'How often we\'ll run all your tests'),
      add_limit("None", "#{gherkin.mobile_alerts_allowance} per month", "#{cucumber.mobile_alerts_allowance} per month", 'Tons!', 'Mobile alerts (Coming Soon!)', 'Receive SMS messages when tests fail', true),
      add_limit('Unlimited',  'Unlimited',  'Unlimited', 'Unlimited', 'Email alerts', 'Receive emails when tests fail'),
  #      add('?', '?', 'SLA', 'There should be different support SLAs?'),
    ]
  end

  def self.features 
    [
      add_feature('Human-friendly tests', 'Write tests in English, not in some arcane scripting language', 'icon-user'),
      add_feature('Unlimited Test files', 'Structure your tests how you want. For example, you might want one per site.', 'icon-file'),
      add_feature('Browse test results', 'Look back over all your past test results', 'icon-list-alt'),
      add_feature('View retrieved pages', 'Look at the cached page we retrieved from your site to see exactly what was returned when we tested it', 'icon-eye-open'),
      add_feature('Use predefines', "Write tests faster and make them easier to maintain by searching for predefined lists of things to check for &ndash; like PHP errors, warnings and notices", 'icon-tags', true),
      # add_feature('Write custom Predefines', 'Write your own predefines, to make writing good tests for your apps quicker, tidier and easier to maintain', 'icon-pencil', true),
      add_feature('Git support', 'Edit your files locally, push them to Citrulu\'s git server, and we\'ll take them from there', 'icon-share', true),
      # add_feature('Run tests on demand', 'Click on a button to schedule a test at any time, and get priority over other users\' runs','icon-play-circle', true),
    ]
  end
  
  private
  
  def self.add_limit(bronze, silver, gold, bespoke, name, description, comingsoon = false) 
    {
      :name => name, 
      :description => description,
      :bronze => bronze,
      :silver => silver,
      :gold => gold,
      :bespoke => bespoke,
      :comingsoon => comingsoon
    }
  end
  
  def self.add_feature(name, description, icon, comingsoon = false) 
    {
      :name => name, 
      :description => description,
      :icon => icon,
      :comingsoon => comingsoon
    }
  end
end