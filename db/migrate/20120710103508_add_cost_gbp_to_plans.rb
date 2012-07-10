class AddCostGbpToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :cost_gbp, :decimal
  end
end
