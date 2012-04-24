FactoryGirl.define do
  factory :plan do
    name_en 'Plan'
    active true
    cost_usd 1000
    
    test_frequency 86400
    number_of_sites 3
    mobile_alerts_allowance 12
    
    allows_custom_predefines false
    allows_retrieved_pages false
    allows_git_support false
    allows_tests_on_demand false

    default false
    sequence(:spreedly_id) { |m| m }
    
    factory :default_plan do
      default true
    end
  end
end
