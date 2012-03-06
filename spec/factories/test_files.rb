# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_file do
    name 'my first test file'
    test_file_text 'This is some test file text'
    user
  end
end
