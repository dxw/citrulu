class ChangePlanLimitsToIntegers < ActiveRecord::Migration
  def up
    change_column :plans, :number_of_sites, :integer
    change_column :plans, :mobile_alerts_allowance, :integer
  end

  def down
    change_column :plans, :number_of_sites, :string
    change_column :plans, :mobile_alerts_allowance, :string
  end
end
