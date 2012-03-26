class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  has_many :test_results, :dependent => :destroy
  accepts_nested_attributes_for :test_results
  
  def number_of_failures
    test_results.select{|t| t.failed?}.count
  end
  
  def has_failures?
    # If there are failed tests, return the number of fails
    # If there are no fails but the group has a message, they all failed. But we don't know that number
    return number_of_failures > 0 || !message.blank?
  end
end
