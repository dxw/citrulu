class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :invitation_code

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code, :email_preference
  
  # Check that the entered invitation code matches this secret string:
#validates_each :invitation_code, :on => :create do |record, attr, value|
#      record.errors.add attr, "isn't valid" unless
#        value && value == "4ec364d986d"
#  end
  
  has_many :test_files
  
  after_initialize :init
  after_create :create_default_test_file 
  after_create :send_welcome_email
  
  private
  
  def init
    # When creating a new user, we want their email preference set to receive test run emails
    self.email_preference  ||= 1
  end
  
  def create_default_test_file
    self.test_files.create(
        :user => self,
        :name => "My first test file",
        :test_file_text => DEFAULT_TEST_FILE
      )
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end
end
