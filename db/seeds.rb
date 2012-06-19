# Make ONE call to Spreedly:
spreedly_plans = Plan.spreedly_plans

# N.B. If any of the following plans don't already exist in Spreedly, this will (correctly) fail
cornichon_free_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Cornichon Free")

cornichon_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Cornichon")
cornichon_price = cornichon_spreedly.price.to_f unless cornichon_spreedly.nil?

gherkin_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Gherkin")
gherkin_price = gherkin_spreedly.price.to_f unless gherkin_spreedly.nil?

Plan.create([
  {
    name_en: 'Cornichon Free',
    default: true,
    free_trial: true,
    spreedly_id: cornichon_free_spreedly.id,
    active: !cornichon_free_spreedly.nil?,
    
    # Limits:
    test_frequency: 21600, # every hour
    number_of_sites: 3,
    mobile_alerts_allowance: 12,
    
    # Features:
    allows_custom_predefines: false,
    allows_retrieved_pages: false,
    allows_git_support: false,
    allows_tests_on_demand: false
  },
  {
    name_en: 'Cornichon',
    default: false,
    cost_usd: cornichon_spreedly.price.to_f, # $14.95 to start with?
    spreedly_id: cornichon_spreedly.id,
    active: !cornichon_spreedly.nil?,
    
    # Limits:
    test_frequency: 3600, # every hour
    number_of_sites: 3,
    mobile_alerts_allowance: 12,
    
    # Features:
    allows_custom_predefines: false,
    allows_retrieved_pages: false,
    allows_git_support: false,
    allows_tests_on_demand: false
  },
  {
    name_en: 'Gherkin',
    cost_usd: gherkin_spreedly.price.to_f, # $49.95 to start with?
    spreedly_id: gherkin_spreedly.id,
    active: !gherkin_spreedly.nil?,
    
    # Limits:
    test_frequency: 60, # every minute
    number_of_sites: 30,
    mobile_alerts_allowance: 120,
    
    # Features:
    allows_custom_predefines: true,
    allows_retrieved_pages: true,
    allows_git_support: true,
    allows_tests_on_demand: true
  }
])