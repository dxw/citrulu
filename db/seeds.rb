# Make ONE call to Spreedly:
spreedly_plans = Plan.spreedly_plans

# N.B. If any of the following plans don't already exist in Spreedly, this will (correctly) fail
cornichon_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Super Tests")
cornichon_price = cornichon_spreedly.price.to_f unless cornichon_spreedly.nil?

gherkin_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Mega Tests")
gherkin_price = gherkin_spreedly.price.to_f unless gherkin_spreedly.nil?

cucumber_spreedly = Plan.get_spreedly_plan(spreedly_plans, "Ultra Tests")
cucumber_price = cucumber_spreedly.price.to_f unless cucumber_spreedly.nil?

Plan.create([
  {
    name_en: 'Super Tests Free',
    default: true,
    free_trial: true,
    spreedly_id: nil,
    active: true,
    
    # Limits:
    test_frequency: 3600, # every hour
    number_of_sites: 2,
    mobile_alerts_allowance: 0,
  },
  {
    name_en: 'Super Tests',
    default: false,
    # cost_usd: cornichon_spreedly.price.to_f, # $5 to start with?
    cost_gbp: cornichon_spreedly.price.to_f, # £5 to start with?
    spreedly_id: cornichon_spreedly.id,
    active: !cornichon_spreedly.nil?,
    
    # Limits:
    test_frequency: 3600, # every hour
    number_of_sites: 2,
    mobile_alerts_allowance: 0,
  },
  {
    name_en: 'Mega Tests',
    # cost_usd: gherkin_spreedly.price.to_f, # $15 to start with?
    cost_gbp: gherkin_spreedly.price.to_f, # £15 to start with?
    spreedly_id: gherkin_spreedly.id,
    active: !gherkin_spreedly.nil?,
    
    # Limits:
    test_frequency: 900, # every 15 minutes
    number_of_sites: 5,
    mobile_alerts_allowance: 15,
  },
  {
    name_en: 'Ultra Tests',
    # cost_usd: cucumber_spreedly.price.to_f, # $50 to start with?
    cost_gbp: cucumber_spreedly.price.to_f, # £50 to start with?
    spreedly_id: cucumber_spreedly.id,
    active: !cucumber_spreedly.nil?,
    
    # Limits:
    test_frequency: 300, # every 5 minutes
    number_of_sites: 50,
    mobile_alerts_allowance: 100,
  },
])