class RemoveAssertionFromTestResult < ActiveRecord::Migration
  def change
    change_table :test_results do |t|
      t.remove :assertion
    end
  end
end
