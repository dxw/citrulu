class TestResult < ActiveRecord::Base
  belongs_to :test_group
  
  def assertion
    self[:assertion].to_test_s
  end
  
  def failed?
    !result
  end
end
