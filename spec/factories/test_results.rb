FactoryGirl.define do
  factory :test_result do
    assertion "i_see"
    value "foobar"
    name ""
    result false
  end
end
