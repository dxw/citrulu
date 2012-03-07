class ChangeTimeRunToDateTimeOnTestRuns < ActiveRecord::Migration
  def up
    change_column :test_runs, :time_run, :datetime
  end

  def down
    change_column :test_runs, :time_run, :time
  end
end
