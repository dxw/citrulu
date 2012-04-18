class AddDefaultToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :default, :boolean
  end
end
