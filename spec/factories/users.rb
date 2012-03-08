# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@dxw.com" }
    sequence(:password) { |m| "P@55w0rd#{m}" }
    sequence(:invitation_code) { |m| "4ec364d986d" }
  end
end
