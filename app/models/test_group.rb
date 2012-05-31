class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  belongs_to :response, :dependent => :destroy

  has_many :test_results, :dependent => :destroy
  accepts_nested_attributes_for :test_results
  accepts_nested_attributes_for :response
 
  def name
    return so if !so.blank?

    "#{method}::#{test_url}"
  end

  def failed_tests
    test_results.select{|t| t.failed?}
  end
  
  def number_of_failed_tests
    # Will be 0 if the whole group failed since test_results will be []
    failed_tests.count
  end
  
  def failed?
    !message.blank?
  end
  
  def has_failed_tests?
    number_of_failed_tests > 0
  end

  def fail_frequency
    # How many times has this page been tested in total?
    total_tests = TestGroup.find_all_by_test_url(test_url).size

    puts total_tests

    # How many times has this page been irretrievable or had a failed assertion?
    total_failed_tests = TestGroup.find_all_by_test_url(test_url).select{|g| g.failed? || g.number_of_failed_tests > 0}.size
    
    puts total_failed_tests

    (total_failed_tests.to_f/total_tests.to_f).round(2)
  end

  def fail_frequency_string
    case fail_frequency*100
    when 0
      'never'
    when 0..5
      'very rarely'
    when 5..45
      'occasionally'
    when 45..55
      'about half the time'
    when 55..95
      'quite often'
    when 100
      'every time it is run'
    when 95..100
      'all the time'
    end
  end
end
