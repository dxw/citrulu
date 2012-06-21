class AddDomainsToTestFiles < ActiveRecord::Migration
  def change
    add_column :test_files, :domains, :text
  end
end
