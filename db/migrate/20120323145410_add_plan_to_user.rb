class AddPlanToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :plan_id, :integer
  end

  def self.down
    remove_column :users, :plan_id
  end
end
