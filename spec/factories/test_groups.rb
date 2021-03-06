FactoryGirl.define do
  factory :test_group, :aliases => [:test_group_with_failures] do
    time_run Time.now
    page_content "Foo"
    response
    
    ignore do 
      successful_results 4
      failed_results 1
    end
    after_create do |test_group, evaluator|
      FactoryGirl.create_list(:successful_test_result, evaluator.successful_results, :test_group => test_group)
      FactoryGirl.create_list(:failed_test_result, evaluator.failed_results, :test_group => test_group)
    end
    
    factory :test_group_no_results do
      successful_results 0
      failed_results 0
      
      factory :failed_test_group do
        sequence(:message) { |n| "Failed to retrieve page#{n}@dxw.com" }
      end
    end
    
    factory :test_group_no_failures do
      failed_results 0
    end
  end
end
