ActiveAdmin.register TestResult do
  filter :id, :as => :numeric
  filter :test_group_id, :as => :numeric
  filter :result, :as => :check_boxes
  filter :original_line
  filter :created_at
  filter :updated_at
end
