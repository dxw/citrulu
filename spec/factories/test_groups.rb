FactoryGirl.define do
  factory :test_group do
    time_run Time.now
    page_content "Foo"
    response_time 237
  end
end
