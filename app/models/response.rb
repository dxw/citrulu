class Response < ActiveRecord::Base
  has_one :test_group
  has_one :test_run, :through => :test_group
  has_one :test_file, :through => :test_group
  has_one :owner, :through => :test_group
  
  def name 
    "#{code}::#{test_group.test_url}::#{test_group.test_run.time_run}"
  end
end
