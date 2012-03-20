class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  has_many :test_results
  accepts_nested_attributes_for :test_results

  def number_of_failures
    test_results.select{|t| t.failed?}.count
  end
  
  def has_failures?
    number_of_failures != 0
  end
end
