class Response < ActiveRecord::Base
  has_one :test_group

  def name 
    "#{code}::#{test_group.test_url}::#{test_group.test_run.time_run}"
  end

  def owner
    test_group.test_run.test_file.user
  end
end
