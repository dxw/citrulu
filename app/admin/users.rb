ActiveAdmin.register User do
  filter :email
  filter :email, :as => :select, collection: proc { User.order(:email) }
  filter :unconfirmed_email
  filter :email_preference, :as => :select
  filter :created_at
  filter :confirmed_at
  filter :last_sign_in_at
  # filter :status # Doesn't work! Boo!
  filter :invitation
  
  
  index do
    column :email
    column :tutorials_opened do |user|
      user.test_files.tutorials.compiled.count
    end
    column :real_files_created do |user|
      user.test_files.not_tutorial.count
    end
    column :files_running do |user|
      user.test_files.running.not_deleted.count
    end
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
    
    column :status
    
    default_actions
  end
  
  show do
    h2 "#{user.email} (##{user.id})"
    
    h3 "Test files:"
    if user.test_files.not_tutorial.blank?
      para "No non-tutorial test files"
    else
      ul do
        user.test_files.not_tutorial.each do |file|
          string = file.name
          string += " (deleted)" if file.deleted?
          li link_to string, admin_test_file_path(file)
        end
      end
    end
    
    
    attributes_table do
      row :plan do
        "#{user.plan.name} (#{user.status})"
      end
      row :created_at
      row :updated_at do
        "#{user.updated_at} (uncomfirmed email: #{user.unconfirmed_email})"
      end
      row :confirmed_at do
        "#{user.confirmed_at} (confirmation sent at #{user.confirmation_sent_at})"
      end
      row :sign_in_count
      row :current_sign_in_at do
        "#{user.current_sign_in_at} (IP: #{user.current_sign_in_ip})"
      end
      row :last_sign_in_at do
        "#{user.last_sign_in_at} (IP: #{user.last_sign_in_ip})"
      end
      row :email_preference
      row :invitation
    end
    
    
    
  end
end
