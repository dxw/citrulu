FactoryGirl.define do
  factory :test_result, :aliases => [:successful_test_result] do
    original_line "I should see foobar"
    result true
    
    factory :failed_test_result do
      result false
    end
  end  
end
