class AddTutorialIdToTestFiles < ActiveRecord::Migration
  def change
    add_column :test_files, :tutorial_id, :integer

  end
end
