class AddSpreedlyIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :spreedly_id, :integer
  end
end
