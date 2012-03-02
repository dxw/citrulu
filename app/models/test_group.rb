class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  has_many :tests
end
