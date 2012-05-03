class AddFreeTrialToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :free_trial, :boolean 
  end
end
