class TestResult < ActiveRecord::Base
  belongs_to :test_group
  has_one :test_run, :through => :test_group
  has_one :test_file, :through => :test_group
  has_one :owner, :through => :test_group

  alias_attribute :name, :original_line
  
  scope :failed, where("result <> ?", true)
  
  def failed?
    !result
  end
end
