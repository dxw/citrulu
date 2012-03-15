require "spec_helper"

describe UserMailer do
  describe 'test notifications' do
    before(:each) do
      user = FactoryGirl.create(:user, :email => 'tom+tester@dxw.com')

      test_file = TestFile.new
      test_file.user_id = user.id
      test_file.name = 'The File'
      test_file.save!

      @test_run1 = TestRun.new
      @test_run1.time_run = Time.now
      @test_run1.test_file_id = test_file.id
      @test_run1.save!

      @test_run2 = TestRun.new
      @test_run2.time_run = Time.now
      @test_run2.test_file_id = test_file.id
      @test_run2.save!

      @test_run3 = TestRun.new
      @test_run3.time_run = Time.now
      @test_run3.test_file_id = test_file.id
      @test_run3.save!

      test_group1 = TestGroup.new
      test_group1.test_run_id = @test_run1.id
      test_group1.time_run = Time.new(2012,01,01)
      test_group1.response_time = 1000
      test_group1.test_url = 'http://dxw.com'
      test_group1.save!

      test_group2 = TestGroup.new
      test_group2.test_run_id = @test_run2.id
      test_group2.time_run = Time.new(2012,01,01)
      test_group2.response_time = 1000
      test_group2.test_url = 'http://example.org'
      test_group2.save!

      test_group3 = TestGroup.new
      test_group3.test_run_id = @test_run3.id
      test_group3.time_run = Time.new(2012,01,01)
      test_group3.response_time = 1000
      test_group3.test_url = 'http://google.com'
      test_group3.save!

      test_group4 = TestGroup.new
      test_group4.test_run_id = @test_run2.id
      test_group4.time_run = Time.new(2012,01,01)
      test_group4.response_time = 1000
      test_group4.test_url = 'http://example.org/test'
      test_group4.save!

      [
        [test_group1, {:assertion=>:i_see, :value=>"a cat", :passed=>true}],
        [test_group1, {:assertion=>:i_see, :value=>"blah", :passed=>false}],
        [test_group1, {:assertion=>:i_not_see, :value=>"your face", :passed=>true}],
        [test_group2, {:assertion=>:i_see, :value=>"a cat", :passed=>false}],
        [test_group2, {:assertion=>:i_see, :value=>"blah", :passed=>false}],
        [test_group4, {:assertion=>:i_not_see, :value=>"your face", :passed=>false}],
        [test_group3, {:assertion=>:i_see, :value=>"a cat", :passed=>true}],
        [test_group3, {:assertion=>:i_see, :value=>"blah", :passed=>true}],
        [test_group3, {:assertion=>:i_not_see, :value=>"your face", :passed=>true}],
      ].each do |t|
        group = t[0]
        test = t[1]
        test_result = TestResult.new
        test_result.test_group_id = group.id
        test_result.assertion = test[:assertion]
        test_result.value = test[:value]
        test_result.name = test[:name]
        test_result.result = test[:passed]
        test_result.save!
      end
    end

    def both_parts email
      yield email.text_part.body
      yield email.html_part.body
    end

    it 'composes an email for a single failure' do
      email = UserMailer.test_notification(@test_run1)

      email.subject.should include('1 of your tests just failed')
      email.to.should == ['tom+tester@dxw.com']

      email.body.should include('<span class="test_value">blah</span><strong> (failed)</strong>')
      email.body.should include('On http://dxw.com')
    end

    it 'composes an email for multiple failures' do
      email = UserMailer.test_notification(@test_run2)

      email.subject.should include('3 of your tests just failed')

      email.body.should include('<span class="test_value">a cat</span><strong> (failed)</strong>')
      email.body.should include('<span class="test_value">blah</span><strong> (failed)</strong>')
      email.body.should include('<span class="test_value">your face</span><strong> (failed)</strong>')
      email.body.should include('On http://example.org')
      email.body.should include('On http://example.org/test')
    end

    it 'composes an email for success' do
      email = UserMailer.test_notification(@test_run3)

      email.subject.should include('All of your tests are passing')

      email.body.should_not include('(failed)')
    end
  end
end
