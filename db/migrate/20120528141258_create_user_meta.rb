class CreateUserMeta < ActiveRecord::Migration
  def change
    create_table :user_meta do |t|
      t.integer :user_id
      t.string :name
      t.datetime :timestamp
    end
  end
end
