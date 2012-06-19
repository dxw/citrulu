class AddNumberOfDomainsToTestFiles < ActiveRecord::Migration
  def change
    add_column :test_files, :number_of_domains, :integer
  end
end
