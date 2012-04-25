desc "Update the 'active' flag on a user based on the Spreedly status and whether they are within the free trial period."
task :check_user_statuses => :environment do
  User.all.each do |user|
    if user.active_subscriber?
      user.status = :paid
    elsif user.is_within_free_trial?
      user.status = :free
    else
      user.status = :inactive
    end
    user.save!
  end
end

