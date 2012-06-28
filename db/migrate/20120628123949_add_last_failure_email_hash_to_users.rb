class AddLastFailureEmailHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_failure_email_hash, :text
  end
end
