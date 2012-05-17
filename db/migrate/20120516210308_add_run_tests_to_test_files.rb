class AddRunTestsToTestFiles < ActiveRecord::Migration
  def change
    add_column :test_files, :run_tests, :boolean
  end
end
