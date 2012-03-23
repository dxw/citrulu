class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :cost_gbp
      t.integer :url_count
      t.integer :test_frequency

      t.timestamps
    end
  end
end
