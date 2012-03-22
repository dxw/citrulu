require "spec_helper"

describe UserMailer do
  before(:each) do
    @user = FactoryGirl.create(:user, :email => 'tom+tester@dxw.com')
  end
  
  describe 'test notifications' do
    before(:each) do
      test_file = FactoryGirl.create(:test_file, :user => @user)
      
      @test_run1 = FactoryGirl.create(:test_run, :test_file => test_file)
      @test_run2 = FactoryGirl.create(:test_run, :test_file => test_file)
      @test_run3 = FactoryGirl.create(:test_run, :test_file => test_file)

      test_group1 = FactoryGirl.create(:test_group_no_results, :test_url => 'http://dxw.com', :test_run => @test_run1)
      test_group2 = FactoryGirl.create(:test_group_no_results, :test_url => 'http://example.org', :test_run => @test_run2)
      test_group3 = FactoryGirl.create(:test_group_no_results, :test_url => 'http://example.org/test', :test_run => @test_run2)
      test_group4 = FactoryGirl.create(:test_group_no_results, :test_url => 'http://google.com', :test_run => @test_run3)
      
      
      FactoryGirl.create(:test_result, :test_group => test_group1, :assertion=>:i_see, :value=>"a cat", :result=>true)
      FactoryGirl.create(:test_result, :test_group => test_group1, :assertion=>:i_see, :value=>"blah", :result=>false)
      FactoryGirl.create(:test_result, :test_group => test_group1, :assertion=>:i_not_see, :value=>"your face", :result=>true)
                                                                   
      FactoryGirl.create(:test_result, :test_group => test_group2, :assertion=>:i_see, :value=>"a cat", :result=>false)
      FactoryGirl.create(:test_result, :test_group => test_group2, :assertion=>:i_see, :value=>"blah", :result=>false)
                                                                   
      FactoryGirl.create(:test_result, :test_group => test_group3, :assertion=>:i_not_see, :value=>"your face", :result=>false)
                                                                   
      FactoryGirl.create(:test_result, :test_group => test_group4, :assertion=>:i_see, :value=>"a cat", :result=>true)
      FactoryGirl.create(:test_result, :test_group => test_group4, :assertion=>:i_see, :value=>"blah", :result=>true)
      FactoryGirl.create(:test_result, :test_group => test_group4, :assertion=>:i_not_see, :value=>"your face", :result=>true)
    end

    def both_parts email
      yield email.text_part.body
      yield Nokogiri::HTML.parse(email.html_part.body.to_s).inner_text
    end

    it 'composes an email for a single failure' do
      email = UserMailer.test_notification(@test_run1)

      email.subject.should include('1 of your tests just failed')
      email.to.should == ['tom+tester@dxw.com']

      both_parts(email) {|body| body.should include('blah (failed)') }
      both_parts(email) {|body| body.should include('On http://dxw.com') }
    end

    it 'composes an email for multiple failures' do
      email = UserMailer.test_notification(@test_run2)

      email.subject.should include('3 of your tests just failed')

      both_parts(email) {|body| body.should include('a cat (failed)') }
      both_parts(email) {|body| body.should include('blah (failed)') }
      both_parts(email) {|body| body.should include('your face (failed)') }
      both_parts(email) {|body| body.should include('On http://example.org') }
      both_parts(email) {|body| body.should include('On http://example.org/test') }
    end

    it 'composes an email for success' do
      email = UserMailer.test_notification(@test_run3)

      email.subject.should include('All of your tests are passing')

      both_parts(email) {|body| body.should_not include('(failed)') }
    end
  end
  
  describe "welcome_email" do
    it "should create an email with the user's email as the subject" do
      UserMailer.welcome_email(@user).to.should == [@user.email]
    end
  end
end
