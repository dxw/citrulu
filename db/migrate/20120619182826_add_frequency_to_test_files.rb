class AddFrequencyToTestFiles < ActiveRecord::Migration
  def change
    add_column :test_files, :frequency, :integer
  end
end
