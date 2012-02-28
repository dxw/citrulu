class AddCompiledTestFileTextToTestFiles < ActiveRecord::Migration
  def self.up
    add_column :test_files, :compiled_test_file_text, :text
  end

  def self.down
    remove_column :test_files, :compiled_test_file_text
  end
end
