class PutAllUsersInDefaultPlan < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.subscribe_to_default_plan
      user.save!
    end
  end

  def down
    User.all.each do |user|
      user.plan_id = nil
      user.save!
    end
  end
end
