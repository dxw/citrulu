class AddTestUrlToTestGroups < ActiveRecord::Migration
  def self.up
    add_column :test_groups, :test_url, :string
  end

  def self.down
    remove_column :test_groups, :test_url
  end
end
