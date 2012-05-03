# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  
  # We'll put :rememberable back in later, once we've figured out how to make it work.
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :trackable, :validatable 

  alias_attribute :name, :email

  attr_accessor :invitation_code

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code, :email_preference, :status
  serialize :status # 4 possible values- :free, :paid, :cancelled, :inactive
  
  
  # Check that the entered invitation code matches this secret string:
  validates_each :invitation_code, :on => :create do |record, attr, value|
    record.errors.add attr, "isn't valid" unless
      value && Invitation.exists?(:code => value) && Invitation.find_by_code(value).enabled
  end
  
  has_many :test_files, :dependent => :destroy
  belongs_to :invitation
  belongs_to :plan
  
  before_create :set_email_preference
  before_create :add_invitation
  before_create :set_default_plan
  after_create :create_default_test_file 
  after_save :update_subscriber
  after_destroy :destroy_subscriber
  
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
  
  def active_subscriber?
    subscriber.active
  end
  
  def status=(status)
    # :free - User is on their free trial
    # :paid - User is on a paid subscription (but has not cancelled, and may still be within the trial period)
    # :cancelled - User has cancelled their subscription but their last month hasn't expired yet
    # :inactive - User has cancelled their subscription and it has expired
    unless [:free, :paid, :cancelled, :inactive].include?(status)
      raise "Status must be one of :free, :paid, :cancelled, :inactive"
    end
    self[:status] = status
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
    bob = subscriber
    if bob && bob.active?
      if bob.recurring
        user.status = :paid
      else
        user.status = :cancelled
      end
    elsif user.is_within_free_trial?
      user.status = :free
    else
      status = :inactive
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
  
  # Update the user's details on Spreedly
  def update_subscription_details(args)
    # TODO: What should we do if the user has no subscription?
    # TODO: Raise an exception if args is empty or invalid?    
    if args.has_key? :update_subscription_plan
      raise ArgumentError.new("You can't update the subscription plan with 'update subscription details'. Use 'update_subscription_plan' instead")
    end
    
    bob = subscriber
    args.each do |key, value|
      if bob.respond_to?("#{key}=")
        bob.send("#{key}=", value)
      else
        raise(NoMethodError, "unknown attribute: #{key} for #{subscriber.inspect}")
      end
    end
    bob.update!
  end  
  
  def update_subscription_plan
    # TODO: probably need to do some work here? e.g. pro-rating?
    if plan.id != subscriber.subscription_plan_id
      subscriber.subscription_plan_id = plan.spreedly_id
      subscriber.update!
    end
  end
  
  # Cancel the subscription without destroying the subscriber
  def cancel_subscription_plan
    if subscriber.stop_auto_renew
      status = :cancelled
      save!
      return true
    end
    #else
      # TODO: raise an error? pass error on (to the controller)?
  end   
  
  def destroy_subscriber
    if subscribed?
      subscriber.destroy
    end
  end
  
  
  private
  
  # Update details on Spreedly
  def update_subscriber
    # TODO: later on, we should maybe assume that every user has a subscription and so raise an error if they dont 
    return if subscriber.nil?
    
    if changed.include?("email")
      update_subscription_details(
        :email => email,
        :screen_name => email
      )
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
  
  def create_default_test_file
    self.test_files.create(
        :user => self,
        :name => "My first test file",
        :test_file_text => DEFAULT_TEST_FILE
      )
  end
end
