FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@dxw.com" }
    sequence(:password) { |m| "P@55w0rd#{m}" }
    invitation
    plan
    
    after_build do |user|
      user.invitation_code = user.invitation.code
    end
  end
end
