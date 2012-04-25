class Invitation < ActiveRecord::Base
  has_many :users

  alias_attribute :name, :code
end
