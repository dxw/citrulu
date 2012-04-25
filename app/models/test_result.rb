class TestResult < ActiveRecord::Base
  belongs_to :test_group

  alias_attribute :name, :original_line

  def failed?
    !result
  end
end
