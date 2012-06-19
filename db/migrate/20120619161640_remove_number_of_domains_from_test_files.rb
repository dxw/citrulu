class RemoveNumberOfDomainsFromTestFiles < ActiveRecord::Migration
  def up
    remove_column :test_files, :number_of_domains
  end

  def down
    add_column :test_files, :number_of_domains, :integer
  end
end
