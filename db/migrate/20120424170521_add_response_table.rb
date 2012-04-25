class AddResponseTable < ActiveRecord::Migration
  def up
    create_table :responses do |t|
      t.integer :response_time
      t.string :content_hash
      t.text :headers
      t.text :content
    end

    add_column :test_groups, :response_id, :integer

    remove_column :test_groups, :response_code
    remove_column :test_groups, :response_time
  end

  def down
    add_column :test_groups, :response_code, :string
    add_column :test_groups, :response_time, :number

    remove_column :test_groups, :response_id
    drop_table :responses
  end
end
