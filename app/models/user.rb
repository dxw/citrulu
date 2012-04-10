# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  
  # We'll put :rememberable back in later, once we've figured out how to make it work.
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :trackable, :validatable 

  attr_accessor :invitation_code

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code, :email_preference
  
  # Check that the entered invitation code matches this secret string:
  validates_each :invitation_code, :on => :create do |record, attr, value|
    record.errors.add attr, "isn't valid" unless
      value && Invitation.exists?(:code => value) && Invitation.find_by_code(value).enabled
  end
  
  has_many :test_files, :dependent => :destroy
  belongs_to :invitation
  belongs_to :plan
  
  after_create :create_default_test_file 
  after_create :add_invitation
  before_save :set_email_preference
  after_save :update_subscription
  after_destroy :destroy_subscription
  
  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end

  def over_quota?
    quota.values.map do |q|
      q[1] != '∞' && q[0] > q[1]
    end.any?
  end

  def quota
    q = {}
    q[:url_count] = [url_count, inf(plan.url_count)]
    q[:test_file_count] = [test_files.count, inf(plan.test_file_count)]
    q
  end

  # TODO - This method is probably redundant
  def subscribe_to_default_plan
    subscribe(Plan.default)
  end
  
  # Create a subscriber record on Spreedly
  def create_subscription
    new_subscriber = RSpreedly::Subscriber.new(
      :customer_id => id,
      :email => email,
      :screen_name => email, #screen_name gets put in the "User Name" field on spreedly
      :subscription_plan_id => plan.spreedly_id
    )
    new_subscriber.save!
  end
  
  def subscriber
    RSpreedly::Subscriber.find(id)
  end
  
  # Update the user's details on Spreedly
  def update_subscription_details(args)
    # TODO: Raise an exception if args is empty or invalid?    
    if args.has_key? :update_subscription_plan
      raise ArgumentError.new("You can't update the subscription plan with 'update subscription details'. Use 'update_subscription_plan' instead")
    end
    
    args.each do |key, value|
      if subscriber.respond_to?("#{key}=")
        subscriber.send("#{key}=", value)
      else
        raise(NoMethodError, "unknown attribute: #{key} for #{subscriber.inspect}")
      end
    end
    subscriber.update!
  end  
  
  def update_subscription_plan
    # TODO: probably need to do some work here? e.g. pro-rating?
    if plan.id != subscriber.subscription_plan_id
      subscriber.subscription_plan_id = plan.spreedly_id
      subscriber.update!
    end
  end
  
  
  private
  
  # Update details on Spreedly
  def update_subscription
    update_subscription_details(
      :email => email,
      :screen_name => email
    )
    
    update_subscription_plan
  end
  
  def destroy_subscription
    RSpreedly::Subscriber.find(id).destroy
  end
  

  def inf val
    val != -1 ? val : '∞'
  end

  def url_count
    test_files.map{|f| CitruluParser.new.compile_tests(f.compiled_test_file_text).length }.sum
  end
  
  def set_email_preference
    # When creating a new user, we want their email preference set to receive test run emails
    self.email_preference ||= 1
  end

  def add_invitation
    self.invitation = Invitation.find_by_code(self.invitation_code)
    save!
  end
  
  def create_default_test_file
    self.test_files.create(
        :user => self,
        :name => "My first test file",
        :test_file_text => DEFAULT_TEST_FILE
      )
  end
end
