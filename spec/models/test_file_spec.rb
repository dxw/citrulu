require 'spec_helper'

describe TestFile do
  before(:each) do
    @test_files = [FactoryGirl.create(:test_file, :compiled_test_file_text => "foobar"), FactoryGirl.create(:test_file, :compiled_test_file_text => nil)]

    @test_runs = [
      [
        FactoryGirl.create(:test_run, :test_file => @test_files[0], :time_run => Time.now), 
        FactoryGirl.create(:test_run, :test_file => @test_files[0], :time_run => Time.now-1)
      ],

      [
        FactoryGirl.create(:test_run, :test_file => @test_files[1], :time_run => Time.now),
        FactoryGirl.create(:test_run, :test_file => @test_files[1], :time_run => Time.now-1)
      ]
    ]
  end

  describe "last_run" do
    it "should return the most recent test run for the file" do
      @test_files[0].last_run.should== @test_runs[0][0]
      @test_files[1].last_run.should== @test_runs[1][0]
    end
  end

  describe "compiled_files" do
    it "Should only return successfully compiled files" do
      TestFile.compiled_files.should==[@test_files[0]]
    end
  end
end
