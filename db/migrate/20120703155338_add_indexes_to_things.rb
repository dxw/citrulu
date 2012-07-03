class AddIndexesToThings < ActiveRecord::Migration
  def change
    add_index :users, :plan_id
    add_index :user_meta, :user_id
    add_index :test_files, :user_id
    add_index :test_files, :tutorial_id
    add_index :test_runs, :test_file_id
    add_index :test_groups, :test_run_id
    add_index :test_groups, :response_id
    add_index :test_results, :test_group_id
  end
end
