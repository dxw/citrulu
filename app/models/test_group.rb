class TestGroup < ActiveRecord::Base
  belongs_to :test_run
  has_many :test_results
end
