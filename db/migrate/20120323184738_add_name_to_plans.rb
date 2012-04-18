class AddNameToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :name_en, :string
  end
end
