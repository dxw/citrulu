class Plan < ActiveRecord::Base
  has_many :users
  
  validates_uniqueness_of :spreedly_id
  validates_presence_of :spreedly_id
  
  def self.default
    Plan.all.select{|p|p.default}.first
  end
end
