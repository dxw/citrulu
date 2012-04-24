class Response < ActiveRecord::Base
  has_one :test_group

  def owner
    test_group.test_run.test_file.user
  end
end
