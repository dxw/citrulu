class AddFeaturesToPlans < ActiveRecord::Migration
  def change
    change_table :plans do |t|
      t.boolean :active
    
      t.remove :test_file_count
    
      t.string :number_of_sites
      t.string :mobile_alerts_allowance
      t.string :email_alerts_allowance

      t.boolean :allows_custom_predefines
      t.boolean :allows_retrieved_pages
      t.boolean :allows_git_support
      t.boolean :allows_tests_on_demand
    
      t.index [:active, :name_en]
      t.index [:active, :spreedly_id]
    end
  end
end
