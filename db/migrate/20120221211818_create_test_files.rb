class CreateTestFiles < ActiveRecord::Migration
  def up
    create_table :test_files do |t|
      t.text :test_file_text
      
      t.timestamps
    end
  end

  def down
    drop_table :test_files
  end
end
