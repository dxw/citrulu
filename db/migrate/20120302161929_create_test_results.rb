class CreateTestResults < ActiveRecord::Migration
  def change
    create_table :test_results do |t|
      t.integer :test_group_id
      t.string :assertion
      t.string :value
      t.string :name
      t.boolean :result

      t.timestamps
    end
  end
end
