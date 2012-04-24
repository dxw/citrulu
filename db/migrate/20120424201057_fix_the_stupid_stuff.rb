class FixTheStupidStuff < ActiveRecord::Migration
  def change
    change_column :test_groups, :response_id, :integer
    change_column :test_groups, :time_run, :datetime
  end
end
