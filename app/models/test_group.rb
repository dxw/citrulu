class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  belongs_to :response, :dependent => :destroy

  has_many :test_results, :dependent => :destroy
  accepts_nested_attributes_for :test_results
  accepts_nested_attributes_for :response
  
  scope :failed, where("message IS NOT NULL AND message <> ''")
  scope :has_failed_tests, where(:id => TestResult.failed.select(:test_group_id)) # cleaner implementation?
  scope :has_failures, where("message IS NOT NULL AND message <> '' OR test_groups.id IN (SELECT test_group_id from test_results where result <> ?)", true)
  
  # The domain part might end with /, ? or end of string. Locate will return 0 (false), when it doesn't find anything:
  DOMAIN_SUBSTRING = "substring(test_url, 1, IF(locate('/', test_url, 9), locate('/', test_url, 9)-1, IF(locate('?', test_url), locate('?', test_url)-1,  LENGTH(test_url))))"
  def self.domains
    domains = self.select("count(#{DOMAIN_SUBSTRING}) as count_domain, #{DOMAIN_SUBSTRING} as domain").group(:domain)
    # to get over the shortcomings in domains: 
    domains.inject({}){ |hash, group| hash.merge!({ group.domain => group.count_domain }) }
  end
  
  scope :urls, select(:test_url)
  
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
