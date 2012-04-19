class TruncateOldResults < ActiveRecord::Migration
  def change  
    TestRun.delete_all
    TestGroup.delete_all
    TestResult.delete_all
  end
end
