class AddEmailConfirmationFieldsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :confirmation_token,    :string
    add_column :users, :confirmed_at,          :datetime
    add_column :users, :confirmation_sent_at,  :datetime
    add_column :users, :unconfirmed_email,     :string
  end

  def down
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
  end
end
