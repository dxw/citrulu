class CreateTestRuns < ActiveRecord::Migration
  def change
    create_table :test_runs do |t|
      t.integer :test_file_id
      t.time :time_run

      t.timestamps
    end
  end
end
