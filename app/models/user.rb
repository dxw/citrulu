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
  
  has_many :test_files
  belongs_to :invitation
  
  after_create :create_default_test_file 
  before_save :add_invitation
  before_save :set_email_preference
  
  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end
  
  private
  
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
