class TestResult < ActiveRecord::Base
  belongs_to :test_group

  def failed?
    !result
  end
end
