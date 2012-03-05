class AddNameToTestFile < ActiveRecord::Migration
  def self.up
    add_column :test_files, :name, :string
  end

  def self.down
    remove_column :test_files, :name
  end
end
