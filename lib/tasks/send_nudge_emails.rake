desc "Send an email to users who haven't created real test files"
task :send_nudge_emails => :environment do
  User.all.each do |user|
    # Replace the below with a condition:
    # true if the user hasn't created a test file
    # AND the user's confirmed date is more than N days in the past
    # false if the user has already been emailed
  
    if false && user.confirmed_at + 15.days > Date.Today 
      UserMailer.nudge(user).deliver
    end
  end    
  
end