class Plan < ActiveRecord::Base
  def self.default
    Plan.all.select{|p|p.default}.first
  end
end
