class TestResult < ActiveRecord::Base
  belongs_to :test_group

  alias_attribute :name, :original_line
  
  scope :failed, where("result <> ?", true)
  
  def failed?
    !result
  end
end
