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
  
  def subscribe(subscription_plan)
    #TODO - plan should be part of the initial user attributes, and subscription_plan should be replaced by plan (i.e the plan of the current user)
    plan = subscription_plan
    subscriber = RSpreedly::Subscriber.new(
      :customer_id => id,
      :email => email,
      :screen_name => email, #screen_name gets put in the "User Name" field on spreedly
      :subscription_plan_id => subscription_plan.spreedly_id
    )
    #TODO: Handle creating new subscribers vs updating subscriptions
    
    subscriber.save!
  end
  
  
  
  private

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
