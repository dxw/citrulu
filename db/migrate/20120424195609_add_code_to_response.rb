class AddCodeToResponse < ActiveRecord::Migration
  def change
    change_table :responses do |t|
      t.string :code
    end
  end
end
