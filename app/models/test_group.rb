class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  belongs_to :response, :dependent => :destroy

  has_many :test_results, :dependent => :destroy
  accepts_nested_attributes_for :test_results
  accepts_nested_attributes_for :response
  
  scope :failed, where("message IS NOT NULL AND message <> ''")
  scope :has_failed_tests, joins(:test_results).where('test_results.result IS NOT ?',true)
  scope :has_failures, joins(:test_results).where("test_results.result IS NOT ? OR (message IS NOT NULL AND message <> '')", true)
  scope :user_groups, lambda{ |user| joins(:test_run => {:test_file => :user}).where(:test_files => { :user_id => user.id }) }
  scope :testing_url, lambda{ |test_url| where(test_url: test_url) }
  scope :past_week, lambda { joins(:test_run).where("test_runs.time_run > ?", Time.now - 7.days) }    
    #http://guides.rubyonrails.org/active_record_querying.html#working-with-times
  
  def name
    return so if !so.blank?

    "#{method}::#{test_url}"
  end

  def failed_tests
    test_results.failed
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
end
