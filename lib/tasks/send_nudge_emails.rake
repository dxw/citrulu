desc "Send an email to users who haven't created real test files"
task :send_nudge_emails => :environment do
  User.all.each do |user|
    # Send an email if the user signed up over 7 days ago, BUT
    # the user has not already been sent this email.
    if user.confirmed_at + 3.days < Date.today && !user.nudge_sent
      user.send_nudge_email
    end
  end    
  
end