desc "Send an email to users who haven't created real test files"
task :send_nudge_emails => :environment do
  User.all.each do |user|
    # Replace the below with a condition:
    # true if the user hasn't created a test file
    # false if the user has already been emailed
  
    if true
      UserMailer.nudge(user).deliver
    end
  end    
  
end