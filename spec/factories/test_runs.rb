FactoryGirl.define do
  factory :test_run do
    time_run Time.now
    test_file
    
    
    factory :test_run_no_failures do
      ignore { groups_count 2 }
      
      after_create do |test_run, evaluator|
        FactoryGirl.create_list(:test_group_no_failures, evaluator.groups_count, :test_run => test_run)
      end
    end
  end
end
