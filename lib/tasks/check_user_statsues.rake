desc "Update the 'active' flag on a user based on the Spreedly status and whether they are within the free trial period."
task :check_user_statuses => :environment do  
  User.all.each do |user|
    subscriber = user.subscriber
    
    if subscriber && if subscriber.active
      if subscriber.recurring
        user.status = :paid
      else
        user.status = :cancelled
      end
    elsif user.is_within_free_trial?
      user.status = :free
    else
      user.status = :inactive
    end
    user.save!
  end
end

