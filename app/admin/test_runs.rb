ActiveAdmin.register TestRun do
  filter :id
  filter :time_run
  filter :test_file_id, :as => :numeric, :label => "Test File ID"
  filter :owner_email, :as => :string
end
