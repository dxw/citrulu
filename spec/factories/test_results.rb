FactoryGirl.define do
  factory :test_result, :aliases => [:successful_test_result] do
    assertion "i_see"
    value "foobar"
    result true
    
    factory :failed_test_result do
      result false
    end
  end  
end
