class Invitation < ActiveRecord::Base
  has_many :users
end
