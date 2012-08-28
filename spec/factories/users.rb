FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@dxw.com" }
    sequence(:password) { |m| "P@55w0rd#{m}" }
    invitation
          
    after_build do |user|
      user.invitation_code = user.invitation.code
      user.class.skip_callback(:save, :after, :update_subscriber)
      # user.class.skip_callback(:create, :before, :set_default_plan)
    end
      
    factory :confirmed_user do
      after_create do |user|
        user.confirm!
      end
    end
  end

end
