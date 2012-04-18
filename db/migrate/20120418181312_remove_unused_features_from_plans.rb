class RemoveUnusedFeaturesFromPlans < ActiveRecord::Migration
  def change
    change_table :plans do |t|
      t.remove :url_count, :email_alerts_allowance
    end
  end
end
