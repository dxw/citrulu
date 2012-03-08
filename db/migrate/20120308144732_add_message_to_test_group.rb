class AddMessageToTestGroup < ActiveRecord::Migration
  def self.up
    add_column :test_groups, :message, :text
  end

  def self.down
    remove_column :test_groups, :message
  end
end
