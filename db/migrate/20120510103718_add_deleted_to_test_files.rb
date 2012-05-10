class AddDeletedToTestFiles < ActiveRecord::Migration
  def change
    add_column :test_files, :deleted, :boolean
  end
end
