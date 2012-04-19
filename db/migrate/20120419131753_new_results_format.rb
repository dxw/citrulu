class NewResultsFormat < ActiveRecord::Migration
  def change
    change_table :test_results do |t|
      t.remove :name, :value
      t.string :original_line
    end

    change_table :test_groups do |t|
      t.string :method, :so
      t.text :data
    end
  end
end
