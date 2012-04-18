# Make ONE call to Spreedly:
spreedly_plans = Plan.spreedly_plans

cornichon_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Cornichon")
cornichon_price = cornichon_spreedly.price.to_f unless cornichon_spreedly.nil?

gherkin_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Gherkin")
gherkin_price = gherkin_spreedly.price.to_f unless gherkin_spreedly.nil?

Plan.create([
  {
    name_en: 'Cornichon',
    default: true,
    cost_usd: cornichon_spreedly.price.to_f, # $14.95 to start with?
    spreedly_id: cornichon_spreedly.id,
    active: !cornichon_spreedly.nil?,
    
    # Limits:
    test_frequency: 21600, # 4 times a day = every 6 hours = 21600
    number_of_sites: 3,
    mobile_alerts_allowance: "12 per month",
    
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
    test_frequency: 900, # 4 times an hour = every 15 mins = 900
    number_of_sites: 30,
    mobile_alerts_allowance: "120 per month",
    
    # Features:
    allows_custom_predefines: true,
    allows_retrieved_pages: true,
    allows_git_support: true,
    allows_tests_on_demand: true
  }
])