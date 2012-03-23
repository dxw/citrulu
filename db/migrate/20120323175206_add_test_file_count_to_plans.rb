class AddTestFileCountToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :test_file_count, :integer
  end
end
