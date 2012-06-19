# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  
  # We'll put :rememberable back in later, once we've figured out how to make it work.
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :trackable, :validatable 

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
    plan = Plan.default
    # Assumption: as long as we're assigning a default plan at this point, it only makes sense for it to be free.
    status == :free 
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
  
  def days_left_of_free_trial
    return 0 unless confirmed?
    FREE_TRIAL_DAYS + 1 - (Date.today - confirmed_at.to_date).to_i
  end
  
  def is_within_free_trial?
    # Calculate free trial from when the user was actually confirmed
    days_left_of_free_trial > 0
  end
  
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
    elsif is_within_free_trial?
      self.status = :free
    else
      self.status = :inactive
    end
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
    else  
      raise "Couldn't find subscriber to update"
    end
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
      
      until !names.include?("#{trimmed_string}#{n}") do 
        n += 1
      end
      "#{trimmed_string}#{n}"
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
      )
    end
  end
  
  def first_tutorial 
    test_files.tutorials.not_deleted.where(tutorial_id: 1).first
  end
  
  def create_new_test_file
    test_files.create!(
      name: new_test_file_name,
      run_tests: true
    )
  end
  
  def create_first_test_file
    test_files.create!(
      name: generate_name("My first Test File"),
      test_file_text: FIRST_TEST_FILE_TEXT,
      run_tests: true
    )
  end
  
  ####################
  # Stats and limits #
  ####################
  def one_week_of_test_runs
    test_runs = TestRun.joins(:test_file => [:user]).where("user_id = :user_id and time_run > :time", {:user_id => self.id, :time => Time.now - 7.days})
  end
  
  
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
