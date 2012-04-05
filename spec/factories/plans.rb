FactoryGirl.define do
  factory :plan do
    name_en 'Plan'
    cost_gbp 1000
    url_count 10
    test_file_count 1
    test_frequency 86400
    default false
    sequence(:spreedly_id) { |m| m }
    
    factory :default_plan do
      default true
    end
  end
end
