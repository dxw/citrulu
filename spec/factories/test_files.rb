# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_file, :aliases => [:compiled_test_file] do
    name 'my first test file'
    test_file_text "On http://example.com\n  I should see foo"
    compiled_test_file_text "On http://example.com\n  I should see foo"
    user
  end
end
