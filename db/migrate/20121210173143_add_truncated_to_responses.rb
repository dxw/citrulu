class AddTruncatedToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :truncated, :boolean
  end
end
