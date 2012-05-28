# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  
  # We'll put :rememberable back in later, once we've figured out how to make it work.
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :trackable, :validatable 

  alias_attribute :name, :email

  attr_accessor :invitation_code

  # Define meta variables as methods: 
  ["nudge_sent"].each do |meta|
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
  

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code, :email_preference
  
  # Check that the entered invitation code matches this secret string:
  validates_each :invitation_code, :on => :create do |record, attr, value|
    record.errors.add attr, "isn't valid" unless
      value && Invitation.exists?(:code => value) && Invitation.find_by_code(value).enabled
  end
  
  has_many :test_files, :dependent => :destroy
  has_many :user_metas
  belongs_to :invitation
  belongs_to :plan
  
  after_create :create_tutorial_test_files 
  after_create :subscribe_to_default_plan
  before_create :add_invitation
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

  def subscribe_to_default_plan
    if self.plan.nil?
      self.plan = Plan.default
    end
  end
  
  def new_test_file_name
    generate_name("New test file")
  end
  
  # Append a number if a name is already taken
  def generate_name(string)
    names = test_files.pluck :name
    if !names.include?(string)
      string
    else 
      n = 1
      until !names.include?("#{string}#{n}") do 
        n += 1
      end
      "#{string}#{n}"
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
  
  def send_nudge_email
    UserMailer.nudge(self).deliver
    
    # This creates a record in user_meta - no need to save the User model.
    nudge_sent = true
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
  end
end
