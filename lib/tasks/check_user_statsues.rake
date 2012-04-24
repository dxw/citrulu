desc "Update the 'active' flag on a user based on the Spreedly status and whether they are within the free trial period."
task :check_user_statuses => :environment do
  User.all.each do |user|
    user.active = (user.subscriber && user.subscriber.active) || user.is_within_free_trial?
    user.save!
  end
end

