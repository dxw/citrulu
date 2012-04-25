class Plan < ActiveRecord::Base
  alias_attribute :name, :name_en

  def self.default
    Plan.all.select{|p|p.default}.first
  end
end
