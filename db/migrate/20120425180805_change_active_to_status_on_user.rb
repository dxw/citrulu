class ChangeActiveToStatusOnUser < ActiveRecord::Migration
  def change
    change_column :users, :active, :string, :default => :free
    rename_column :users, :active, :status
    
    # assuming we're not going to run this After we've accepted paying customers...
    User.all.each do |u|
      u.status = :free
      u.save!
    end
  end
end
