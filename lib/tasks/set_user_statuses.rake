desc "Update the 'active' flag on a user based on the Spreedly status and whether they are within the free trial period."
task :set_user_statuses => :environment do
  User.set_statuses
end

