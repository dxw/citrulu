class RemoveFeatureColumnsFromPlans < ActiveRecord::Migration
  def up
    remove_column :plans, :allows_custom_predefines
    remove_column :plans, :allows_retrieved_pages
    remove_column :plans, :allows_git_support
    remove_column :plans, :allows_tests_on_demand
  end

  def down
    add_column :plans, :allows_custom_predefines, :boolean
    add_column :plans, :allows_retrieved_pages, :boolean
    add_column :plans, :allows_git_support, :boolean
    add_column :plans, :allows_tests_on_demand, :boolean
  end
end
