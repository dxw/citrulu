class TestResult < ActiveRecord::Base
  belongs_to :test_group

  attr_accessor :original_line
  
  def assertion
    self[:assertion].to_test_s
  end
  
  def failed?
    !result
  end
end
