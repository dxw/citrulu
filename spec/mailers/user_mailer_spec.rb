require "spec_helper"

describe UserMailer do
  describe 'test notifications' do
    before(:each) do
      @user = User.new
      @user.email = 'tom+tester@dxw.com'
      @user.password = 'foobar'
      @user.invitation_code = '4ec364d986d'
      @user.save!

      @test_file = TestFile.new
      @test_file.user_id = @user.id
      @test_file.name = 'The File'
      @test_file.save!

      @test_run = TestRun.new
      @test_run.time_run = Time.now
      @test_run.test_file_id = @test_file.id
      @test_run.save!

      @test_group = TestGroup.new
      @test_group.test_run_id = @test_run.id
      @test_group.time_run = Time.new(2012,01,01)
      @test_group.response_time = 1000
      @test_group.save!

      [
        {:assertion=>:i_see, :value=>"a cat", :passed=>true},
        {:assertion=>:i_see, :value=>"blah", :passed=>false},
        {:assertion=>:i_not_see, :value=>"your face", :passed=>true}
      ].each do |test|
        @test_result = TestResult.new
        @test_result.test_group_id = @test_group.id
        @test_result.assertion = test[:assertion]
        @test_result.value = test[:value]
        @test_result.name = test[:name]
        @test_result.result = test[:passed]
        @test_result.save!
      end
    end

    it 'composes emails' do
      email = UserMailer.test_notification(@test_group)

      email.subject.should include('1 test just failed')
      email.to.should == ['tom+tester@dxw.com']
    end
  end
end
