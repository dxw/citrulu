ActiveAdmin.register User do
  index do
    column :email
    column :unconfirmed_email
    column :email_preference
    column :sign_in_count
    column :invitation do |user|
      div user.invitation.description if user.invitation
    end
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :confirmed_at
    
    default_actions
  end
end
