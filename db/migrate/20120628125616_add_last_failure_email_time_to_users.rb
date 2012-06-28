class AddLastFailureEmailTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_failure_email_time, :time
  end
end
