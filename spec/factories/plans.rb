FactoryGirl.define do
  factory :plan, :aliases => [:active_plan] do
    name_en 'Plan'
    active true
    cost_usd 1000
    cost_gbp 800
    
    test_frequency 86400
    number_of_sites 3
    mobile_alerts_allowance 12

    default false
    sequence(:spreedly_id) { |m| m }
    
    factory :default_plan do
      default true
    end
  end
end
