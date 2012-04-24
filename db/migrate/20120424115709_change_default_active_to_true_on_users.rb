class ChangeDefaultActiveToTrueOnUsers < ActiveRecord::Migration
  def up
    change_column :users, :active, :boolean, :default => true
  end

  def down
    change_column :users, :active, :boolean, :default => false
  end
end
