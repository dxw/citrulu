# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  
  # We'll put :rememberable back in later, once we've figured out how to make it work.
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :trackable, :validatable, :token_authenticatable

  alias_attribute :name, :email

  attr_accessor :invitation_code

  def self.define_meta_methods(meta)
    define_method meta do
      # Assumption: that there's only one instance of any one meta variable
      m = user_metas.where(name: meta).first
      return true unless m.nil?
    end
    
    define_method "#{meta}_time" do
      # Assumption: that there's only one instance of any one meta variable
      m = user_metas.where(name: meta).first
      return m.timestamp unless m.nil?
    end
    
    define_method "#{meta}=" do |value|
      user_metas.where(name: meta).destroy_all
      if value == true 
        user_metas.create(name: meta, timestamp: Time.now)
      end
    end
  end
  
  # Define meta variables as methods: 
  ["nudge_sent"].each do |meta|
    self.define_meta_methods(meta)
  end
  

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code, :email_preference, :status
  serialize :status # 4 possible values- :free, :paid, :cancelled, :inactive
  
  has_many :test_files, :dependent => :destroy
  has_many :user_metas
  belongs_to :invitation
  belongs_to :plan
  
  before_create :set_email_preference
  before_create :set_default_plan
  after_create :create_tutorial_test_files 
  after_save :update_subscriber
  after_destroy :cancel_subscription
  
  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end
  
  def set_default_plan
    self.plan = Plan.default
    # Assumption: as long as we're assigning a default plan at this point, it only makes sense for it to be free.
    self.status = :free 
  end
  
  # Can the user use the service?
  def active?
    status != :inactive # i.e. status == :free || status == :paid || status == :cancelled 
  end
  
  def status=(new_status)
    # :free - User is on their free trial
    # :paid - User is on a paid subscription (but has not cancelled, and may still be within the trial period)
    # :cancelled - User has cancelled their subscription but their last month hasn't expired yet
    # :inactive - User has cancelled their subscription and it has expired
    unless [:free, :paid, :cancelled, :inactive].include?(new_status)
      raise "Status must be one of :free, :paid, :cancelled, :inactive"
    end
    self[:status] = new_status
  end


  # THESE TWO METHODS WILL BE REQUIRED when we impose free trial limits.
  # Until then, leave them commented out so we can be sure that nothing is trying to use them:
  
  # def days_left_of_free_trial
  #   return 0 unless confirmed?
  #   FREE_TRIAL_DAYS + 1 - (Date.today - confirmed_at.to_date).to_i
  # end
  # 
  # def is_within_free_trial?
  #   # Calculate free trial from when the user was actually confirmed
  #   days_left_of_free_trial > 0
  # end
  
  # Look at Spreedly to check what the status of each user should be 
  def set_status
    # The "self"s seem to be required because of the "def status=" above. Not sure why...
    bob = subscriber
    if bob && bob.active
      if bob.recurring
        self.status = :paid
      else
        self.status = :cancelled
      end
    # REMOVE THIS WEN WE LAUNCH:
    else
      # While we're in beta everyone should stay on the free plan
      self.status = :free
    end
    # PUT THE FOLLOWING LINES IN WHEN WE LAUNCH:
    # elsif is_within_free_trial?
    #   self.status = :free
    # else
    #   self.status = :inactive
    # end
    save!
  end
  
  
  def self.set_statuses
    all.each{|user| user.set_status}
  end
  

  ###################
  # SUBSCRIBER CRUD #
  ###################
  
  # Create a subscriber record on Spreedly
  def create_subscriber
    # If you try and subscribe twice, you get: 
    #   MultiXml::ParseError: Start tag expected, '<' not found
    if subscribed?
      raise "A subscriber record has already been created for that user"
    end
    
    new_subscriber = RSpreedly::Subscriber.new(
      :customer_id => id,
      :email => email,
      :screen_name => email, #screen_name gets put in the "User Name" field on spreedly
    )
    new_subscriber.save!
  end
  
  def create_or_update_subscriber
    if subscribed?
      update_subscriber
    else
      create_subscriber
    end
  end
  
  def subscriber
    RSpreedly::Subscriber.find(id)
  end
  
  def subscribed?
    !subscriber.nil?
  end
  
  def change_plan(plan_id)
    new_plan = Plan.find(plan_id)

    if subscriber.change_subscription_plan(new_plan.spreedly_id)
      plan = new_plan
      save!
      
      # We've changed the plan so we need to update all the test file frequencies
      update_test_file_frequencies
    else  
      raise "Couldn't find subscriber to update"
    end
  end
  
  # Update the frequency of all the test files to reflect a change of plan
  def update_test_file_frequencies
    test_files.each{|f| f.update_attribute(:frequency, plan.test_frequency)}
  end
  
  def destroy_subscriber
    if subscribed?
      subscriber.destroy
      
      if is_within_free_trial?
        self.status = :free
      else
        self.status = :inactive
      end
      save!
    end
  end
  
  
  #######################
  # New Test Files etc. #
  #######################
  
  def new_test_file_name
    generate_name("New test file")
  end
  
  # Append a number if a name is already taken
  def generate_name(string)
    names = test_files.pluck :name
    if !names.include?(string)
      string
    else
      # Find the existing tail number if any:
      number_suffix = string.match /\d+$/
      if number_suffix.nil?
        n = 1
      else
        n = number_suffix[0].to_i + 1 
      end
      
      #remove the numbers from the end of the string:
      trimmed_string = string.gsub /\d+$/, ""
      
      until !names.include?("#{trimmed_string} #{n}") do 
        n += 1
      end
      "#{trimmed_string} #{n}"
    end
  end
  
  def create_tutorial_test_files
    # Need to do the each in reverse order so that the most recently created is the first one
    TUTORIAL_TEST_FILES.reverse_each do |f|
      test_files.create!(
        :name => generate_name(f[:name]),
        :tutorial_id => f[:id],
        :test_file_text => f[:text],
        :run_tests => false,
        frequency: plan.test_frequency 
      )
    end
  end
  
  def first_tutorial 
    test_files.tutorials.not_deleted.where(tutorial_id: 1).first
  end
  
  def create_new_test_file
    test_files.create!(
      name: new_test_file_name,
      run_tests: true,
      frequency: plan.test_frequency
    )
  end
  
  def create_first_test_file
    test_files.create!(
      name: generate_name("My first Test File"),
      test_file_text: FIRST_TEST_FILE_TEXT,
      run_tests: true,
      frequency: plan.test_frequency
    )
  end
  
  ####################
  # Stats and limits #
  ####################
  
  def one_week_of_test_runs
    TestRun.user_test_runs(self).past_week
  end
  
  def number_of_test_runs_in_past_week
    return 0 if one_week_of_test_runs.blank?
    one_week_of_test_runs.size 
  end
  def failed_runs_in_past_week
    return [] if one_week_of_test_runs.blank?
    one_week_of_test_runs.select{ |r| r.has_failures? }
  end
  def number_of_failed_test_runs_in_past_week
    failed_runs_in_past_week.size
  end
  def number_of_successful_test_runs_in_past_week
    number_of_test_runs_in_past_week - number_of_failed_test_runs_in_past_week
  end
  
  def test_groups 
    TestGroup.user_groups(self)
  end
  
  def groups_with_failures
    # As in ALL test groups with failures EVER
    test_groups.has_failures
  end
  
  def groups_from_past_week
    test_groups.past_week
  end

  def groups_with_failures_in_past_week
    test_groups.has_failures.past_week
  end
  def urls_with_failures_in_past_week
    test_groups.has_failures.past_week.urls.count(:group => :test_url)
  end
  def domains_with_failures_in_past_week
    test_groups.has_failures.past_week.domains
    
    # Slow solution: get the groups 
    # test_groups.has_failures.past_week.map{ |group| CitruluParser.domain(group.test_url) }.compact.uniq 
  end
  
  def broken_pages_list(urls_with_failures)
    broken_pages = []
    urls_with_failures.each do |url, number_of_failures|
      broken_pages << {
        :url => url,
        :fails_this_week => number_of_failures,
        :badness => fail_frequency(url),
      }
    end
    broken_pages.sort!{ |a,b| b[:fails_this_week] <=> a[:fails_this_week] }
  end
  
  # Success rates of domains in the past week
  def domains_list
    failures_list = domains_with_failures_in_past_week
    
    domains = []
    test_groups.past_week.domains.each do |domain, count|
      domains << {
        :domain => domain,
        :failure_rate => 100*failures_list[domain].to_f / count, :precision => 0
      }
    end
    return domains
  end
  
  def fail_frequency(test_url)
    # i.e. how many times has this url failed for this user EVER?
    # How many times has this page been tested in total?
    total_tests = TestGroup.user_groups(self).testing_url(test_url)
    total_tests = total_tests.length

    # How many times has this page been irretrievable or had a failed assertion?
    total_failed_tests = TestGroup.user_groups(self).testing_url(test_url).has_failures.length

    (total_failed_tests.to_f/total_tests.to_f).round(2)
  end

  
  def pages_average_times
    # Merge the (url => response_time) results of all of the test runs from the last week 
    array_of_hashes = one_week_of_test_runs.map{ |test_run| test_run.pages_average_times } 
    array_of_hashes.reduce{ |bighash, this_hash | bighash.merge(this_hash){ |url, oldval, newval| (newval+oldval)/2} }
  end
  
  # The number of unique domains across all active test files
  def number_of_domains
    domains.count
  end
  def number_of_running_files
    test_files.running.not_deleted.count
  end
  
  # The list of unique domains across all active test files
  def domains
    # Approach: Compile all the files and concatenate the results together, then call 'count_domains' on the whole lot
    relevant_test_files = test_files.running.not_deleted.compiled
    relevant_test_files.collect{|f| f.domains}.compact.flatten.uniq
  end
  

  # def average_fix_speed
  #   return 0 if test_runs.size == 0
  # 
  #   in_fail_spree = false
  #   fail_sprees = []
  #   start_fail = nil
  # 
  #   test_runs.sort{|a,b| a <=> b}.each do |run|
  #     if !in_fail_spree && run.has_failures?
  #       in_fail_spree = true
  #       start_fail = run
  #     elsif in_fail_spree && !run.has_failures?
  #       in_fail_spree = false
  # 
  #       fail_sprees << run.time_run - start_fail.time_run
  #     end
  #   end
  # 
  #   fail_sprees.inject(0.0){|sum,n| sum+n} / fail_sprees.size
  # end
  
  # -- END STATS
  
  
  def send_nudge_email
    UserMailer.nudge(self).deliver
    
    # This creates a record in user_meta - no need to save the User model.
    nudge_sent = true
  end
  
  # This sets the from field on Devise emails:
  def headers_for(action)
    {:from => "Citrulu <contact@citrulu.com>"}
  end

  def enqueue_test_files
    self.test_files.each do |file|
      file.enqueue
    end
  end

  def priority_enqueue_test_files
    self.test_files.each do |file|
      file.priority_enqueue
    end
  end

  def prioritise_test_files
    self.test_files.each do |file|
      file.prioritise
    end
  end
  
  private
  
  # Update details on Spreedly
  def update_subscriber
    # TODO: later on, we should maybe assume that every user has a subscription and so raise an error if they dont 
    return if subscriber.nil?
    
    if changed.include?("email")
      subscriber.update_attributes(
        :email => email,
        :screen_name => email
      )
    end
  end
  
  def cancel_subscription
    return if subscriber.nil?
    
    if subscriber.stop_auto_renew
      self.status = :cancelled
      save!
    #else
      # TODO - handle errors? (set on subscriber when stop_auto_renew returns false)
    end
  end
  
  def inf val
    val != -1 ? val : '∞'
  end
  
  def set_email_preference
    # When creating a new user, we want their email preference set to receive test run emails
    self.email_preference ||= 1
  end

  def add_invitation
    self.invitation = Invitation.find_by_code(self.invitation_code)
  end
  
end
