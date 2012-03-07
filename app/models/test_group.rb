class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  has_many :test_results

  def number_of_failures
    test_results.select{|t| t.failed?}.count
  end
end
