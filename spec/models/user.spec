describe User do
  setup do
    @user = User.new
  end
  
  it "should be invalid without an email address and password" do
    @user.should_not_be_valid
    @user.email = 'a@a.com'
	@user.should_not_be_valid
	@user.password= 'password1'
    @user.should_be_valid
  end
  
  #it "should increment the number of failed password attempts" do
	#user = FactoryGirl.create(:user)
	#user.
	
end