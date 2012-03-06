class AddResponseCodeToTestGroup < ActiveRecord::Migration
  def self.up
    add_column :test_groups, :response_code, :text
  end

  def self.down
    remove_column :test_groups, :response_code
  end
end
