class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :test_file_id
      t.time :time_run
      t.text :result

      t.timestamps
    end
  end
end
