class AddEmailPreferenceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_preference, :integer
  end
end
