class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :invitation_code

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code
  
  # Check that the entered invitation code matches this secret string:
  validates_each :invitation_code, :on => :create do |record, attr, value|
      record.errors.add attr, "isn't valid" unless
        value && value == "4ec364d986d"
  end
  
  has_many :test_files
  
  after_create :create_default_test_file 
  
  private
  
  def create_default_test_file
    self.test_files.create(
        :user => self,
        :name => "My first test file",
        :test_file_text => DEFAULT_TEST_FILE
      )
  end
end
