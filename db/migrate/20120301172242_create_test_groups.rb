class CreateTestGroups < ActiveRecord::Migration
  def change
    create_table :test_groups do |t|
      t.integer :test_run_id
      t.text :page_content
      t.integer :response_time
      t.time :time_run

      t.timestamps
    end
  end
end
