class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  has_many :test_results, :dependent => :destroy
  accepts_nested_attributes_for :test_results
  
  def number_of_failed_tests
    # Will be 0 if the whole group failed since test_results will be []
    test_results.select{|t| t.failed?}.count
  end
  
  def failed?
    !message.blank?
  end
  
  def has_failed_tests?
    number_of_failed_tests > 0
  end
end
